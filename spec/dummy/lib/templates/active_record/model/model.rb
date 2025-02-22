<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  # alias_attribute :to_s, :name
  audited
  strip_attributes

<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %><%= ', optional: false' if attribute.required? %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>
end
<% end -%>
