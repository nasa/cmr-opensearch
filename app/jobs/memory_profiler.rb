class MemoryProfiler < JobBase
  def execute
    Rails.logger.info("Memory Stats Profile: #{GC.stat}")
    Rails.logger.info("Connection pool size: #{ActiveRecord::Base.connection_pool.connections.size}")
    Rails.logger.info("Starting Database Polling")
    #Rails.logger.info("Current Thread Connection Auto Commit: #{ActiveRecord::Base.connection.raw_connection.auto_commit}")
    ActiveRecord::Base.connection_pool.connections.each_with_index { |connection,number| Rails.logger.info("Connection Number:#{number + 1} Open Transactions:#{connection.open_transactions.to_s} Last Used: #{Time.now - connection.last_use}s ago")}
  end
end