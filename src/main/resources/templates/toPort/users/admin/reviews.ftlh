<#import "/spring.ftl" as spring />
<#import "*/utils/hangar.ftlh" as hangar />

@import controllers.sugar.Requests.OreRequest
@import ore.OreConfig
@import ore.db.Model
@import ore.markdown.MarkdownRenderer
@import ore.models.admin.Review
@import ore.models.project.{Project, ReviewState, Version}
@import util.StringFormatterUtils._
@import util.syntax._
@import views.html.helper.CSPNonce

@(mostRecentUnfinishedReview: Option[Review], reviews: Seq[(Model[Review], Option[String])], project: Project, version: Model[Version])(implicit messages: Messages,
        request: OreRequest[_], config: OreConfig, flash: Flash, renderer: MarkdownRenderer, assetsFinder: AssetsFinder)

@projectRoutes = @{controllers.project.routes.Projects}
@versionRoutes = @{controllers.project.routes.Versions}

@scripts = {
    <script @CSPNonce.attr type="text/javascript" src="<@spring.url "javascripts/review.js" />"></script>
    <script @CSPNonce.attr>versionPath = '@helper.urlEncode(project.ownerName)/@helper.urlEncode(project.slug)/versions/@helper.urlEncode(version.name)'</script>
}

@layout.base(messages("review.title", project.name, version.name), scripts) {

    <div class="row">
        <div class="col-md-12  header-flags">
            <div class="clearfix">
                <h1 class="pull-left">@project.name <i>@version.versionString</i></h1>
            </div>
            <p class="user date pull-left">
                <a href="@routes.Users.showProjects(project.ownerName)">
                    <strong>@project.ownerName</strong>
                </a>
                released this version on @prettifyDate(version.createdAt)
            </p>
            @if(!version.reviewState.isChecked) {
                <div class="pull-right">
                    <span class="btn-group-sm">
                        <a href="#" class="btn btn-info btn-skip-review">@if(version.reviewState != ReviewState.Backlog) { Remove from queue } else { Add to queue }</a>
                        <a href="@projectRoutes.show(project.ownerName, project.slug)" class="btn btn-info">Project Page</a>
                        <a href="@versionRoutes.downloadJar(project.ownerName, project.slug, version.versionString, None)" class="btn btn-info">Download File</a>
                    </span>
                    <span class="btn-group-sm">
                    @if(mostRecentUnfinishedReview.isDefined) {
                        @if(request.headerData.isCurrentUser(mostRecentUnfinishedReview.get.userId)) {
                            <button class="btn btn-review-stop btn-danger"><i class="fas fa-stop-circle"></i> <@spring.message "review.stop" /></button>
                            <button class="btn btn-review-approve btn-success"><i class="fas fa-thumbs-up"></i> <@spring.message "user.queue.approve" /></button>
                            <button class="btn btn-review-approve-partial btn-success"><i class="fas fa-thumbs-up"></i> <@spring.message "user.queue.approvePartial" /></button>
                        } else {
                            <button class="btn btn-review-takeover btn-danger"><i class="fas fa-clipboard"></i> <@spring.message "review.takeover" /></button>
                        }
                    } else {
                        <button class="btn btn-review-start btn-success"><i class="fas fa-terminal"></i> <@spring.message "review.start" /></button>
                    }
                    </span>
                </div>
            } else {
                <div class="pull-right">
                    <span class="btn-group-sm">
                        <a href="" class="btn btn-danger btn-review-reopen">Undo approval</a>
                    </span>
                </div>
            }
        </div>
    </div>
    @if(mostRecentUnfinishedReview.isDefined) {
        @if(request.headerData.isCurrentUser(mostRecentUnfinishedReview.get.userId)) {
            <div class="row">
                <div class="col-md-12">
                    <div class="input-group" style="width: 100%;
                        margin-top: 1em;">
                        <textarea type="text" class="form-control textarea-addmessage" placeholder="Message"></textarea>
                        <div class="input-group-addon btn btn-review-addmessage-submit btn-primary"><i class="fas fa-clipboard"></i> <@spring.message "review.addmessage" /></div>
                    </div>
                </div>
            </div>
        }
    }
    <div class="row version-description">
        <div class="col-md-12">
            <h2><@spring.message "review.log" /></h2>
        </div>
        @if(reviews.isEmpty) {
            <div class="col-md-12">
                <div class="alert-review alert alert-info" role="alert">
                    <i class="fas fa-info-circle"></i>
                    This version is not under review
                </div>
            </div>
        }

        <div class="col-md-12">
            <table class="table table-condensed setting-no-border table-review-log">
                <tbody>
                @reviews.reverse.zipWithIndex.map { case (t, index) =>
                    @defining((t._1, t._2)) { case (item, name) =>
                        @if(item.endedAt.isDefined) {
                            @if(reviews.size > (reviews.size - index)) {
                                @if(prettifyDateAndTime(item.endedAt.get).equalsIgnoreCase(prettifyDateAndTime(reviews.reverse(reviews.size - index - 1)._1.createdAt))) {
                                    <tr>
                                        <td>@prettifyDateAndTime(item.endedAt.get)</td>
                                        <td>

                                            <strong>@name.getOrElse("Unknown")</strong>
                                            took over from
                                            <strong>@name.getOrElse("Unknown")</strong>
                                            @if(!item.decodeMessages.exists(_.isTakeover)) {
                                                <i>- no message provided -</i>
                                            } else {
                                                <i>@item.decodeMessages.filter(_.isTakeover).head.render</i>
                                            }
                                        </td>
                                    </tr>
                                } else {
                                    <tr>
                                        <td>@prettifyDateAndTime(item.endedAt.get)</td>
                                        <td><strong>@name.getOrElse("Unknown")</strong> stopped</td>
                                    </tr>
                                }
                            } else {
                                @if(version.approvedAt.isDefined) {
                                    <tr>
                                        <td>@prettifyDateAndTime(item.endedAt.get)</td>
                                        <td><strong>@name.getOrElse("Unknown")</strong> approved</td>
                                    </tr>
                                } else {
                                    <tr>
                                        <td>@prettifyDateAndTime(item.endedAt.get)</td>
                                        <td>
                                            <strong>@name.getOrElse("Unknown")</strong>
                                            stopped
                                            <br>
                                            @if(!item.decodeMessages.exists(_.isStop)) {
                                                <i>- no message provided -</i>
                                            } else {
                                                <i>@item.decodeMessages.filter(_.isStop).head.render</i>
                                            }
                                        </td>
                                    </tr>
                                }
                            }
                        }
                        @item.decodeMessages.filterNot(_.isTakeover).filterNot(_.isStop).reverse.map { message =>
                            <tr>
                                <td>@message.getTime(messages.lang.locale)</td>
                                <td>
                                    <strong>@name.getOrElse("Unknown")</strong>
                                    added message
                                    <br>
                                    <i>@message.render</i>
                                </td>
                            </tr>
                        }
                        <tr>
                            <td>@prettifyDateAndTime(item.createdAt.value)</td>
                            <td><strong>@name.getOrElse("Unknown")</strong> started a review</td>
                        </tr>
                    }
                }
                </tbody>
            </table>
        </div>
    </div>


    <div class="modal fade" id="modal-review-stop" tabindex="-1" role="dialog" aria-labelledby="modal-review-stop">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="<@spring.message "general.close" />">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title"><@spring.message "review.stop" /></h4>
                </div>
                <div class="modal-body">
                    <@spring.message "review.whystop" />
                    <br>
                    <textarea class="textarea-stop form-control" rows="3"></textarea>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default"><@spring.message "general.cancel" /></button>
                    <button class="btn btn-review-stop-submit btn-primary"><i class="fas fa-stop-circle"></i> <@spring.message "review.stop" /></button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="modal-review-takeover" tabindex="-1" role="dialog" aria-labelledby="modal-review-takeover">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="<@spring.message "general.close" />">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title"><@spring.message "review.takeover" /></h4>
                </div>
                <div class="modal-body">
                    <@spring.message "review.whytakeover" />
                    <br>
                    <textarea class="textarea-takeover form-control" rows="3"></textarea>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default"><@spring.message "general.cancel" /></button>
                    <button class="btn btn-review-takeover-submit btn-primary"><i class="fas fa-clipboard"></i> <@spring.message "review.takeover" /></button>
                </div>
            </div>
        </div>
    </div>
}
