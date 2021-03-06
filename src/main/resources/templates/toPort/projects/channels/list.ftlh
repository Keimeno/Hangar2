<#import "/spring.ftl" as spring />
<#import "*/utils/hangar.ftlh" as hangar />

@import controllers.sugar.Requests.OreRequest
@import models.viewhelper.ProjectData
@import ore.OreConfig
@import ore.db.Model
@import ore.models.project.Channel
@import views.html.helper.{CSPNonce, CSRF, form}
@(p: ProjectData, channels: Seq[(Model[Channel], Int)])(implicit messages: Messages, flash: Flash, request: OreRequest[_], config: OreConfig, assetsFinder: AssetsFinder)

@channelRoutes = @{controllers.project.routes.Channels}
@versionRoutes = @{controllers.project.routes.Versions}

@scripts = {
    <script type="text/javascript" src="<@spring.url "javascripts/channelManage.js" />"></script>
    <script @CSPNonce.attr>
            PROJECT_OWNER = '@p.project.ownerName';
            PROJECT_SLUG = '@p.project.slug';
            $(function() {
                initChannelManager(
                        "#channel-new", "", "@config.defaultChannelColor.hex", "New channel",
                        "@channelRoutes.create(p.project.ownerName, p.project.slug)",
                        "post", "Create channel", false
                );
            });
    </script>
}

@layout.base(messages("channel.list.title", p.project.ownerName, p.project.slug), scripts) {

    <div class="row">
            <div class="col-md-6 col-md-offset-3">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><@spring.message "channel.list.title" /></h3>
                    </div>
                    <div class="panel-body">
                        <p class="minor create-blurb">
                            <@spring.message "channel.list.description" />
                        </p>

                        <table class="table no-border centered">
                            <tbody>
                                @channels.map { case (channel, versions) =>
                                    <tr>
                                        <td>
                                            <div class="channel" style="background-color: @channel.color.hex">@channel.name</div>
                                        </td>
                                        <td>
                                            <div class="btn btn-sm yellow" data-toggle="modal" data-target="#channel-settings" id="channel-edit-@channel.id">Edit</div>
                                        </td>
                                        @if(channels.size > 1) {
                                            <td>
                                                <div class="btn btn-sm yellow"
                                                    @if(versions > 0) {
                                                        id="channel-delete-@channel.id" data-toggle="modal"
                                                        data-target="#modal-delete">
                                                    } else {
                                                        id="channel-delete-@channel.id" data-channel-delete="safe-delete"
                                                        data-channel-id="@channel.id">

                                                        @form(action = channelRoutes.delete(
                                                            p.project.ownerName, p.project.slug, channel.name),
                                                            Symbol("id") -> s"form-delete-${channel.id}",
                                                            Symbol("class") -> "form-channel-delete") {
                                                            @CSRF.formField
                                                        }
                                                    }
                                                Delete
                                                </div>
                                            </td>
                                        }
                                        <script @CSPNonce.attr>
                                          $(function() {
                                              initChannelDelete('#channel-delete-@channel.id', '@channel.name', @versions);
                                              initChannelManager(
                                                      "#channel-edit-@channel.id", "@channel.name", "@channel.color.hex",
                                                      "Edit channel", "@channelRoutes.save(
                                                        p.project.ownerName, p.project.slug, channel.name)",
                                                      "post", "Save changes", @channel.isNonReviewed
                                              );
                                          });
                                      </script>
                                  </tr>
                                }
                            </tbody>
                        </table>
                        <a href="@versionRoutes.showList(p.project.ownerName, p.project.slug)"
                           class="pull-left btn btn-default">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <a href="#" id="channel-new" class="pull-right btn btn-primary"
                           @if(channels.size >= config.ore.projects.maxChannels) {
                               disabled data-toggle="tooltip" data-placement="left"
                               title="<@spring.message "channel.edit.maxReached" />"
                           } else {
                               data-toggle="modal" data-target="#channel-settings"
                           }
                        >
                            <i class="fas fa-plus"></i>
                        </a>
                        @projects.channels.helper.modalManage()
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="modal-delete" tabindex="-1" role="dialog" aria-labelledby="label-delete">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="<@spring.message "general.close" />">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="label-delete"><@spring.message "channel.delete" /></h4>
                </div>
                <div class="modal-body">
                    <p><@spring.message "channel.delete.info" /></p>
                    <p class="minor">
                        <strong class="version-count"></strong> <i><@spring.message "channel.delete.info.versions" /></i>
                    </p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        <@spring.message "general.cancel" />
                    </button>
                    <form method="post" action="#" class="form-channel-delete">
                        @CSRF.formField
                        <button type="submit" class="btn btn-danger"><@spring.message "channel.delete" /></button>
                    </form>
                </div>
            </div>
        </div>

}
