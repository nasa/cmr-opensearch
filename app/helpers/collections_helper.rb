module CollectionsHelper
  def truncate_link(link)
    title = link.title ? link.title : 'undefined'
    # The href and title come from CMR metadata, so they are escaped before the markup is
    # marked html_safe; without this a quote in either one closes the attribute.
    markup = "<a target='_blank' class='ext' href='#{ERB::Util.html_escape(link.href)}' " \
             "title='#{ERB::Util.html_escape(link.title)}'>#{ERB::Util.html_escape(title.truncate(64))}</a>"
    markup.html_safe
  end
end
