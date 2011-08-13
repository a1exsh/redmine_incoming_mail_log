class IncomingMailsController < ApplicationController
  unloadable

  layout 'admin'
  before_filter :require_admin
  before_filter :find_incoming_mail, :only => [:show, :destroy]

  def index
    # TODO: search & pagination
    @mails = IncomingMail.all
  end

  def show
  end

  def destroy
  end

  private

  def find_incoming_mail
    @mail = IncomingMail.find(params[:id])
  end
end
