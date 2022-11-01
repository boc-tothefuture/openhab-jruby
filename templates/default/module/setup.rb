# frozen_string_literal: true

def init
  sections :header, :box_info, :pre_docstring, T("docstring"), :children,
           :constant_summary, [T("docstring")], :inherited_constants,
           :attribute_summary, [:item_summary], :inherited_attributes,
           :method_summary, [T("docstring"), :item_summary], :inherited_methods,
           :methodmissing, [T("method_details")],
           :attribute_details, [T("method_details")],
           :method_details_list, [T("method_details")]
end
