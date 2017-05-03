class Carto::Api::PermissionsController < ::Api::ApplicationController

  ssl_required :update

  def update
    permission = CartoDB::Permission.where(id: params[:id]).first

    return head(404) if permission.nil?
    return head(401) unless permission.is_owner?(current_user)

    begin
      acl = params[:acl]
      acl ||= []
      permission.acl = acl.map { |entry| entry.deep_symbolize_keys }
    rescue CartoDB::PermissionError => e
      CartoDB.notify_exception(e)
      return head(400)
    end

    permission.save

    render json: permission.to_poro
  end

end
