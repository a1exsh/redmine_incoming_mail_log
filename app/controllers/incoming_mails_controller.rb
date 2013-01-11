class IncomingMailsController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin
  before_filter :find_incoming_mail, :only => [:show, :destroy]

  def index
    @mails = IncomingMail

    @subject_like = params[:subject]
    @mails = @mails.subject_like(@subject_like) if @subject_like.present?

    @sender_like = params[:sender]
    @mails = @mails.sender_like(@sender_like) if @sender_like.present?

    @projects = Project.all
    if params[:project].present?
      begin
        @project = Project.find(params[:project])
        @mails = @mails.for_project(@project.identifier)
      rescue ActiveRecord::RecordNotFound
      end
    end

    @unhandled_only = (params[:unhandled_only] ||= "1") == "1"
    @mails = @mails.unhandled if @unhandled_only

    @limit = per_page_option

    @mail_count = @mails.count
    @mail_pages = Paginator.new(self, @mail_count, @limit, params[:page])
    @offset ||= @mail_pages.current.offset

    @mails = @mails.all(:order => "created_on DESC",
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
