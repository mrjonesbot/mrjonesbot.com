class GenerateFitCheckJob < ApplicationJob
  queue_as :default

  def perform(assessment_token, job_description)
    career_context = YAML.load_file(Rails.root.join("config/career_context.yml"))

    system_prompt = build_system_prompt(career_context)

    begin
      chat = RubyLLM.chat(model: "claude-haiku-4-5-20251001")
      chat.with_instructions(system_prompt)
      response = chat.ask(
        "Here is the job description to evaluate:\n\n#{job_description}"
      )

      content = response.content
      fit_level = extract_fit_level(content)

      Turbo::StreamsChannel.broadcast_replace_to(
        "fit_check_#{assessment_token}",
        target: "fit_check_result",
        partial: "fit_checks/result",
        locals: { content: content, fit_level: fit_level }
      )
    rescue => e
      Rails.logger.error "Error generating fit check: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      Turbo::StreamsChannel.broadcast_replace_to(
        "fit_check_#{assessment_token}",
        target: "fit_check_result",
        partial: "fit_checks/error",
        locals: { message: "Sorry, something went wrong analyzing this job description. Please try again." }
      )
    end
  end

  private

  def build_system_prompt(context)
    profile = context["profile"]
    experiences = context["experiences"]
    expertise = context["technical_expertise"]
    self_assessment = context["self_assessment"]
    compensation = context["compensation"]
    values = context["values"]

    experience_text = experiences.map { |e|
      "#{e['role']} at #{e['company']} (#{e['period']}): #{e['ai_context']}"
    }.join("\n")

    <<~PROMPT
      You are an honest career fit assessor for #{profile['name']}, a #{profile['tagline']}.

      Current role: #{profile['current_role']}

      Experience:
      #{experience_text}

      Technical expertise: #{expertise.join(', ')}

      Self-assessed strengths: #{self_assessment['strong'].join(', ')}
      Self-assessed moderate areas: #{self_assessment['moderate'].join(', ')}
      Self-assessed gaps: #{self_assessment['gaps'].join(', ')}

      Values: #{values.join('; ')}

      Target compensation: #{compensation['target_salary']}

      Your task: Given a job description, provide a brutally honest assessment of Nathan's fit.
      If the job description lists a salary range, note whether it aligns with Nathan's target compensation.
      Be real — don't oversell. If it's not a fit, say so clearly.

      Structure your response EXACTLY like this:

      **Overall Fit: [Strong Fit / Moderate Fit / Weak Fit / Not a Fit]**

      **Where Nathan Matches**
      - [Specific strength that maps to a JD requirement]
      - [Another match]

      **Honest Gaps**
      - [Specific gap or mismatch]
      - [Another gap]

      **Bottom Line**
      [1-2 sentence honest summary]

      Rules:
      - The first line MUST start with **Overall Fit:** followed by exactly one of: Strong Fit, Moderate Fit, Weak Fit, Not a Fit
      - Be specific — reference actual JD requirements and Nathan's actual experience
      - Don't pad the strengths section if there aren't many matches
      - If the role requires skills Nathan doesn't have, be upfront about it
      - Keep it concise — no more than 200 words total
    PROMPT
  end

  def extract_fit_level(content)
    # Scan for the "Overall Fit:" line anywhere in the response
    fit_line = content.to_s.lines.find { |l| l.downcase.include?("overall fit") }.to_s.downcase
    if fit_line.include?("strong fit")
      "strong"
    elsif fit_line.include?("not a fit")
      "not_a_fit"
    elsif fit_line.include?("weak fit")
      "weak"
    elsif fit_line.include?("moderate fit")
      "moderate"
    else
      "moderate"
    end
  end
end
