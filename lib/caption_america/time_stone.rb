module CaptionAmerica
  module TimeStone

    TIMESTAMP_REGEXES = [
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})[:,;](?<frames>\d{2})$/,
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})$/,
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})\.(?<ms>\d{3})$/,
    ]

    DEFAULT_FPS = 29.97

    class CueTime
      attr_accessor :hours, :minutes, :seconds, :milliseconds, :frames

      def initialize
        @hours = 0
        @mintes = 0
        @seconds = 0
        @milliseconds = 0
        @frames = 0
      end
    end

    def self.parse_cue(timecode)
      TIMESTAMP_REGEXES.each do |regex|
        match = timecode.match regex

        return timecode_regex_match_to_cue_time(match) if match
      end

      raise InvalidTimestampError
    end

    def self.to_milliseconds(timecode, fps: DEFAULT_FPS)
      cue = self.parse_cue(timecode)

      ms = (cue.frames.to_f / fps) * 1000
      ms += cue.milliseconds
      ms += cue.seconds * 1000
      ms += cue.minutes * 60 * 1000
      ms += cue.hours * 60 * 60 * 1000

      ms.round
    end

    def self.to_frames(timecode, drop_frame: false, fps: DEFAULT_FPS)
      cue = self.parse_cue(timecode)

      # milliseconds or frames should be zero (one or the other), so we'll
      # just calculate boh
      seconds = cue.seconds
      seconds += cue.minutes * 60
      seconds += cue.hours * 60 * 60
      #seconds += cue.milliseconds.round

      total_frames = (seconds * fps) + cue.frames

      if drop_frame
        total_minutes = (cue.hours * 60) + cue.minutes

        frames_to_drop = (0...total_minutes).to_a.map { |i| i if i % 10 != 0 }.compact!.size * 2
        total_frames = total_frames - frames_to_drop
      end

      return total_frames
    end

private

    def self.timecode_regex_match_to_cue_time(match)
      CueTime.new.tap do |cue|
        cue.hours = match[:hours].to_i
        cue.minutes = match[:minutes].to_i
        cue.seconds = match[:seconds].to_i

        if match.named_captures["frames"] != nil
          cue.frames = match[:frames].to_i
        end

        if match.named_captures["ms"] != nil
          cue.milliseconds = match[:ms].to_i
        end
      end
    end
  end
end