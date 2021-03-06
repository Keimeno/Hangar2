<#import "/spring.ftl" as spring />
<#import "*/utils/hangar.ftlh" as hangar />

@import java.time.{Instant, OffsetDateTime, ZoneOffset}

@import controllers.sugar.Requests.OreRequest
@import ore.OreConfig
@import ore.markdown.MarkdownRenderer
@import ore.models.project.{Note, Project}
@import ore.models.user.User
@import util.StringFormatterUtils._
@import util.syntax._
@import views.html.helper.CSPNonce
@(project: Project, notes: Seq[(Note, Option[User])])(implicit messages: Messages, request: OreRequest[_], config: OreConfig, flash: Flash, renderer: MarkdownRenderer, assetsFinder: AssetsFinder)


@projectRoutes = @{controllers.project.routes.Projects}
@scripts = {
    <script @CSPNonce.attr type="text/javascript" src="<@spring.url "javascripts/notes.js" />"></script>
    <script @CSPNonce.attr>resourcePath = '@project.ownerName/@project.slug'</script>
}

@layout.base(messages("notes"), scripts) {
    <div class="row">
        <div class="col-md-12  header-flags">
            <div class="clearfix">
                <h1 class="pull-left"><@spring.message "notes" /> for <a href="@projectRoutes.show(project.ownerName, project.slug)">@project.ownerName/@project.slug</a></h1>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-12">
            <div class="input-group" style="width: 100%;
                margin-top: 1em;">
                <textarea type="text" class="form-control textarea-addmessage" placeholder="Message"></textarea>
                <div class="input-group-addon btn btn-note-addmessage-submit btn-primary"><i class="fas fa-clipboard"></i> <@spring.message "notes.addmessage" /></div>
            </div>
        </div>
    </div>
    <div class="row version-description">
        <div class="col-md-12">
            <h2><@spring.message "notes" /></h2>
        </div>
        @if(notes.isEmpty) {
            <div class="col-md-12">
                <div class="alert-notes alert alert-info" role="alert">
                    <i class="fas fa-info-circle"></i>
                    This project does not have notes
                </div>
            </div>
        }

        <div class="col-md-12">
            <table class="table table-condensed setting-no-border table-notes-log">
                <tbody>
                @notes.map { case (note, user) =>
                <tr>
                    <td class="note-fixed-with">@prettifyDateAndTime(OffsetDateTime.ofInstant(Instant.ofEpochMilli(note.time), ZoneOffset.UTC))</td>
                    <td class="note-fixed-with"><strong>@user.map(_.name).getOrElse("Unknown")</strong></td>
                    <td>@note.render</td>
                </tr>
                }
                </tbody>
            </table>
        </div>
    </div>
}
