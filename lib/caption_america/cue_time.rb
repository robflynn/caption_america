module CaptionAmerica
  class CueTime
    TIMESTAMP_REGEXES = [
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})[:,;](?<frames>\d{2})$/,
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})$/,
      /^(?<hours>\d{2})[:,;](?<minutes>\d{2})[:,;](?<seconds>\d{2})\.(?<ms>\d{3})$/,
    ]

    DEFAULT_FPS = 29.97

    attr_accessor :hours, :minutes, :seconds, :milliseconds, :frames

    def initialize
      @hours = 0
      @mintes = 0
      @seconds = 0
      @milliseconds = 0
      @frames = 0
    end

    def self.timestamp_match?(timecode)
      TIMESTAMP_REGEXES.each do |regex|
        matched = timecode.match regex

        return matched if matched
      end

      false
    end

    def self.parse(timecode)
      matched = timestamp_match?(timecode)

      raise InvalidTimestampError unless matched

      return timecode_regex_match_to_cue_time(matched)
    end

    def self.to_milliseconds(timecode, fps: DEFAULT_FPS)
      cue = self.parse(timecode)

      ms = (cue.frames.to_f / fps) * 1000
      ms += cue.milliseconds
      ms += cue.seconds * 1000
      ms += cue.minutes * 60 * 1000
      ms += cue.hours * 60 * 60 * 1000

      ms.round
    end

    def self.to_timecode(ms)
      time = ms.to_f
      msec = "%.3d" % (time % 1000)
      time /= 1000
      time_list = []
      3.times { time_list.unshift("%.2d" % (time % 60)) ; time /= 60 }
      [ time_list.join(":"), msec].join(',')
    end

    def self.to_frames(timecode, drop_frame: true, fps: DEFAULT_FPS)
      cue = self.parse(timecode)

      drop_frames = (fps * 0.066666).round
      time_base = fps.round

      # let's convert milliseconds to frames if that's what we're working with
      # frames are more common so we'll let milliseconds ovverride
      normalized_frames = cue.frames
      if cue.milliseconds > 0
        normalized_frames = ((cue.milliseconds / 1000) * fps).round
      end

      hour_frames = time_base * 60 * 60
      minute_frames = time_base * 60
      total_minutes = (60 * cue.hours) + cue.minutes
      frame_number = ((hour_frames * cue.hours) +
                      (minute_frames * cue.minutes) +
                      (time_base * cue.seconds) + normalized_frames)

      if drop_frame
        frame_number -= drop_frames * (total_minutes - (total_minutes % 10))
      end

      return frame_number
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