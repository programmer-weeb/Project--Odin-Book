module ApplicationHelper
  def display_name(user)
    user.profile&.display_name.presence || user.email.split("@").first
  end

  def user_handle(user)
    "@#{user.email.split('@').first}"
  end

  def friendly_timestamp(value)
    value.strftime("%b %-d, %Y at %-I:%M %p")
  end

  def flash_classes(type)
    case type.to_sym
    when :notice
      "border border-[#e8e6dc] bg-[#faf9f5] text-[#3d3d3a]"
    when :alert
      "border border-[#e4c7c1] bg-[#fff7f5] text-[#8f2f2f]"
    else
      "border border-[#e8e6dc] bg-white text-[#3d3d3a]"
    end
  end

  def app_shell_classes
    "min-h-screen bg-[#f5f4ed] text-[#141413]"
  end

  def primary_button_classes
    "inline-flex items-center justify-center rounded-lg bg-[#c96442] px-4 py-2 text-sm font-medium text-[#faf9f5] transition hover:bg-[#b85a3b] focus:outline-none focus:ring-2 focus:ring-[#3898ec] focus:ring-offset-2"
  end

  def secondary_button_classes
    "inline-flex items-center justify-center rounded-lg border border-[#e8e6dc] bg-[#faf9f5] px-4 py-2 text-sm font-medium text-[#3d3d3a] transition hover:border-[#d1cfc5] hover:bg-white focus:outline-none focus:ring-2 focus:ring-[#3898ec] focus:ring-offset-2"
  end

  def subtle_button_classes
    "inline-flex items-center justify-center rounded-lg px-3 py-2 text-sm font-medium text-[#5e5d59] transition hover:bg-[#ece9df] hover:text-[#141413] focus:outline-none focus:ring-2 focus:ring-[#3898ec] focus:ring-offset-2"
  end

  def input_classes
    "mt-2 block w-full rounded-lg border border-[#d9d4c7] bg-[#faf9f5] px-4 py-3 text-sm text-[#141413] placeholder:text-[#87867f] focus:border-[#3898ec] focus:outline-none focus:ring-2 focus:ring-[#3898ec]/20"
  end

  def textarea_classes
    "#{input_classes} min-h-32 resize-y"
  end

  def card_classes
    "rounded-lg border border-[#e8e6dc] bg-[#faf9f5] shadow-[0_0_0_1px_rgba(232,230,220,0.4)]"
  end

  def status_badge_classes(status)
    case status.to_s
    when "accepted", "friend"
      "bg-[#e4efe5] text-[#375341]"
    when "pending"
      "bg-[#f3ebdf] text-[#72553b]"
    when "rejected"
      "bg-[#f5dfda] text-[#8f2f2f]"
    else
      "bg-[#ece9df] text-[#5e5d59]"
    end
  end
end
