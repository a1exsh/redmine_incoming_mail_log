module RedmineIncomingMailLog
  class TracingLoggerWrapper
    def initialize(logger, trace_proc)
      @logger = logger
      @trace_proc = trace_proc
    end

    (Logger::Severity.constants).map{|n| n.downcase}.each do |name|
      # Define 'seen_error', 'seen_error?' and 'error' methods (ditto
      # for 'info', etc.)
      define_method(:"seen_#{name}") do
        instance_variable_set(:"@seen_#{name}", true)
      end

      define_method(:"seen_#{name}?") do
        instance_variable_defined?(:"@seen_#{name}")
      end

      define_method(name.to_sym) do |msg=nil|
        self.send(:"seen_#{name}")
        if @logger.send(name.to_sym, msg)
          @trace_proc.call(name, msg)
          true
        end
      end
    end
  end
end
