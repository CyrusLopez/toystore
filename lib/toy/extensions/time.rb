module Toy
  module Extensions
    module Time
      def to_store(value)
        if value.nil? || value == ''
          nil
        else
          time_class = ::Time.try(:zone).present? ? ::Time.zone : ::Time
          time = value.is_a?(::Time) ? value : time_class.parse(value.to_s)
          # strip milliseconds as Ruby does micro and bson does milli and rounding rounded wrong
          at(time.to_i).utc if time
        end
      end

      def from_store(value)
        if ::Time.try(:zone).present? && value.present?
          value.in_time_zone(::Time.zone)
        else
          value
        end
      end
    end
  end
end

class Time
  extend Toy::Extensions::Time
end