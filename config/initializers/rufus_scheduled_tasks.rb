# This initializer will run all the CMR OpenSearch scheduled tasks
# If various durations are needed for various scheduler tasks, different scheduler runs should be used for individual
# tasks
require 'rufus-scheduler'

s = Rufus::Scheduler.singleton
# recurrent midnight run, no overlap of tasks, tasks executed in their own threads not in the scheduler thread
s.cron'00 00 * * *', :overlap => false, :timeout => '10m' do
  begin
    eosdis_tagger = EosdisTagger.new
    # decided with single post instead of the many posts (one per provider)
    eosdis_tagger.execute_scheduled_task_single_post
  rescue Rufus::Scheduler::TimeoutError
    Rails.logger.info "10m TIMEOUT occured for run of scheduled EOSDIS tagging task: #{Time.now}"
  end
end
