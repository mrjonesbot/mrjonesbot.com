module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(text.to_s).html_safe
  end

  def json_ld_tags
    site = Rails.application.credentials.site
    profile = site[:profile]

    schemas = []

    schemas << {
      "@context" => "https://schema.org",
      "@type" => "Person",
      "name" => profile[:name],
      "jobTitle" => profile[:title],
      "description" => profile[:tagline],
      "url" => root_url,
      "image" => "#{root_url}icon.png",
      "email" => "mailto:#{profile[:email]}",
      "address" => {
        "@type" => "PostalAddress",
        "addressLocality" => "Chicago",
        "addressRegion" => "IL",
        "addressCountry" => "US"
      },
      "worksFor" => {
        "@type" => "Organization",
        "name" => "RiseKit",
        "url" => "https://risekit.co"
      },
      "alumniOf" => {
        "@type" => "EducationalOrganization",
        "name" => "Northwestern Kellogg"
      },
      "knowsAbout" => site[:stack],
      "sameAs" => [
        "https://github.com/mrjonesbot",
        "https://www.kellogg.northwestern.edu/"
      ]
    }

    schemas << {
      "@context" => "https://schema.org",
      "@type" => "WebSite",
      "name" => profile[:name],
      "url" => root_url,
      "description" => profile[:tagline]
    }

    safe_join(schemas.map { |s| tag.script(s.to_json.html_safe, type: "application/ld+json") })
  end
end
