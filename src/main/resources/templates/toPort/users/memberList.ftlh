<#import "/spring.ftl" as spring />
<#import "*/utils/hangar.ftlh" as hangar />

@import ore.OreConfig
@import ore.models.user.role.UserRoleModel
@import util.syntax._
@import views.html.helper.{CSRF, form}
@import views.html.utils.userAvatar
@* MemberData? with perms *@
@import controllers.sugar.Requests.OreRequest
@import models.viewhelper.JoinableData
@import ore.permission.Permission
@(j: JoinableData[_ <: UserRoleModel[_], _], perms: Permission, editable: Boolean = false, removeCall: Call = null,
        settingsCall: Call = null, saveCall: Call = null)(implicit messages: Messages, config: OreConfig, request: OreRequest[_])

<!-- TODO: Pagination -->

@if(j.members.nonEmpty) {

    @if(editable && perms.has(Permission.ManageSubjectMembers)) {
        @users.invite.roleSelect(
            roleCategory = j.roleCategory,
            id = "select-role",
            classes = "pull-right",
            hidden = true
        )

        <!-- Row template -->
        <ul style="display: none;">
            <li id="row-user" class="list-group-item">
                <input type="hidden" />
                @userAvatar(None, clazz = "user-avatar-xs")
                <a class="username"></a>
                <i class="fas fa-times user-cancel"></i>
                @users.invite.roleSelect(roleCategory = j.roleCategory, classes="pull-right")
            </li>
        </ul>

        <!-- Delete modal -->
        <div class="modal fade" id="modal-user-delete" tabindex="-1" role="dialog" aria-labelledby="label-user-delete">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal"
                                aria-label="<@spring.message "general.close" />">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <h4 class="modal-title" id="label-user-delete"><@spring.message "project.removeMember" /></h4>
                    </div>
                    <div class="modal-body"><@spring.message "project.removeMember.confirm" /></div>
                    <div class="modal-footer">
                        @form(action = removeCall, Symbol("class") -> "form-inline") {
                            @CSRF.formField
                            <input type="hidden" name="username" />
                            <button type="button" class="btn btn-default" data-dismiss="modal">
                                <@spring.message "general.close" />
                            </button>
                            <button type="submit" class="btn btn-danger"><@spring.message "general.remove" /></button>
                        }
                    </div>
                </div>
            </div>
        </div>
    }

    <div class="alert alert-danger member-error" style="display: none">
        <span>error</span>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="pull-left panel-title"><@spring.message "project.settings.members" /></h3>

            @if(perms.has(Permission.ManageSubjectMembers)) {
                <div class="pull-right">
                    @if(!editable && settingsCall != null) {
                        <a href="@settingsCall"
                           class="btn yellow btn-xs">
                            <i class="fas fa-pencil-alt"></i>
                        </a>
                    }

                    @if(saveCall != null) {
                        @form(action = saveCall, Symbol("id") -> "save") {
                            @CSRF.formField
                            <button class="btn-members-save btn btn-default btn-panel btn-xs" data-toggle="tooltip"
                                    data-placement="top" data-title="<@spring.message "org.users.save" />" style="display: none;">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        }
                    }
                </div>
            }
        </div>

        <ul class="list-members list-group">
            <!-- Member list -->
            @j.filteredMembers.map { case (role, user) =>
                <li class="list-group-item">
                    @userAvatar(Some(user.name), user.avatarUrl, clazz = "user-avatar-xs")
                <a class="username" href="@routes.Users.showProjects(user.name)">
                @user.name
                </a>
                    <p style="display: none;" class="role-id">@role.id</p>
                    @if(editable && perms.has(Permission.ManageSubjectMembers) && !role.role.permissions.has(Permission.IsOrganizationOwner)) {
                        <a href="#">
                            <i style="padding-left:5px" class="fas fa-trash" data-toggle="modal" data-target="#modal-user-delete"></i>
                        </a>
                        <a href="#"><i style="padding-left:5px" class="fas fa-edit"></i></a>
                    }

                <span class="minor pull-right">
                @if(!role.isAccepted) {
                    <span class="minor">(Invited as @role.role.title)</span>
                } else {
                    @role.role.title
                }
                </span>

                </li>
            }

            <!-- User search -->
            @if(perms.has(Permission.ManageSubjectMembers) && editable) {
                <li class="list-group-item">
                    @users.invite.userSearch()
                </li>
            }

        </ul>
    </div>

}
