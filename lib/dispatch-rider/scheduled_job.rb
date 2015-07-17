require "active_record"

# @note: Later this could be pulled out to its own gem and included depending on what ORM the user
# prefers. Something like:
# @example
#  gem "dispatch_rider-active_record"
#  gem "dispatch_rider-rom" # Ruby Object Mapper
#  gem "dispatch_rider-mongo_mapper"
#  gem "dispatch_rider-ohm"
module DispatchRider
  class ScheduledJob < ActiveRecord::Base
    class << self
      def publisher
        @publisher ||= Publisher.new
      end

      # @param [ActiveSupport::Duration] every
      # @example: DispatchRider::ScheduledJob.publish_due_jobs every 1.minute
      def publish_due_jobs(every: nil)
        loop {
          claim_stub = get_new_claim_stub
          due.unclaimed.update_all claim_stub
          due.claimed_by(claim_stub[:claim_id]).find_each(&:publish)
          every ? sleep(every) : break # until the next loop
        }
      end

      private

      def get_new_claim_stub
        { claim_id: SecureRandom.uuid, claim_expires_at: 30.minutes.from_now }
      end
    end

    serialize :destinations
    serialize :message

    validates :scheduled_at,
              :destinations,
              :message,
              presence: true

    scope :due, -> (time = Time.now) { where "scheduled_at <= ?", time }
    scope :claimed_by, -> (claim_id) { where(claim_id: claim_id).where "claim_expires_at > ?", Time.now }
    scope :unclaimed, -> { where "claim_expires_at IS NULL OR claim_expires_at <= ?", Time.now }

    def publish
      publisher.publish(destinations: destinations, message: message)

      destroy # once published
    end

    private

    delegate :publisher, to: :"self.class"
  end
end

require_relative "scheduled_job/migration"
