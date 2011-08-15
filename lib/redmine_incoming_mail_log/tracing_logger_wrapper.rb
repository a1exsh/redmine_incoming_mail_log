module RedmineIncomingMailLog
  class TracingLoggerWrapper
    def initialize(logger, trace_proc)
      @logger = logger
      @trace_proc = trace_proc
    end

    (Logger::Severity.constants).map{|n| n.downcase.to_sym}.each do |name|
      define_method(name) do |msg|
        levelq_sym = "#{name}?".to_sym
        if !@logger.respond_to?(levelq_sym) || @logger.send(levelq_sym)
          @trace_proc.call(name.to_s.upcase, msg)
        end
        @logger.send(name, msg)
      end
    end
  end
end
