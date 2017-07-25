
# This was created for NCRs 11012624 and 11012632.  We found a concurrency bug in Rails' ActiveRecord ConnectionPool class.  The problem
# seems to be causing connections to be shared across threads sporadically.  We added this module as a stop gap to help verify that we have not
# received a bad or in use connection.  The verify method fails if a connection is in a transaction that already started.
module ConnectionVerifier

  MESSAGE = "Detected connection with existing transaction open"

  def self.verify_not_in_transaction
    conn = ActiveRecord::Base.connection
    raw_conn = conn.raw_connection
    if raw_conn.auto_commit == false || conn.open_transactions != 0
      message = "#{MESSAGE} auto_commit is #{raw_conn.auto_commit}, open transactions is #{conn.open_transactions}"
      Rails.logger.error(message)
      raise RestErrors::ServiceUnavailable.new(message)
    end
  end


end