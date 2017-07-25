class JobBase

  def run()
    begin
      execute
    rescue => exception
      Rails.logger.error("Caught exception in scheduled job #{self.class.name}: #{exception.message}\n#{exception.inspect}\n#{exception.backtrace.join("\n")}\n")
    ensure
      ActiveRecord::Base.connection_pool.release_connection if ActiveRecord::Base.connection_pool.active_connection?
    end
  end

end