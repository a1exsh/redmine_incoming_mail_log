class IncomingMailsController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin
  before_filter :find_incoming_mail, :only => [:show, :destroy]

  def index
    conditions = {}

    @projects = Project.all
    if params[:project].present?
      begin
        @project = Project.find(params[:project]) 
        conditions.merge!(:target_project => @project.identifier)
      rescue ActiveRecord::RecordNotFound
      end
    end

    @limit = per_page_option

    @mail_count = IncomingMail.count(:conditions => conditions)
    @mail_pages = Paginator.new(self, @mail_count, @limit, params[:page])
    @offset ||= @mail_pages.current.offset

    # TODO: search
    @mails = IncomingMail.all(:conditions => conditions,
                              :order => "created_on DESC",
                              :offset => @offset,
                              :limit => @limit)
  end

  def show
    respond_to do |format|
      format.html
      format.text { render :text => @mail.content }
    end
  end

  def destroy
    @mail.destroy
    redirect_to :back
  rescue RedirectBackError
    redirect_to :action => 'index'
  end

  private

  def find_incoming_mail
    @mail = IncomingMail.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
