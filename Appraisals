active_support_versions = %w(
  5.1.0
  5.2.0
  6.0.0.rc1
)

active_support_versions.each do |version|
  appraise "active_support_#{version}" do
    gem "activesupport", "~> #{version}"
  end
end
