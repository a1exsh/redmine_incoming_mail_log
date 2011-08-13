class IncomingMail < ActiveRecord::Base
  unloadable

  def project
    @project ||= Project.visible.find_by_identifier(target_project)
  end

  def target_project=(identifier)
    @project = nil
    super identifier
  end

  def reload(*args)
    @project = nil
    super *args
  end
end
