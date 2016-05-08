# -*- coding: utf-8 -*-

require 'open-uri'
require 'nokogiri'

Plugin.create(:mikutter_lgtm) do

  @image = nil

  def get_image
    url = 'http://www.lgtm.in/g'
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    @image = doc.xpath("//input[@id='imageUrl']").attribute('value')
  end

  command(:mikutter_lgtm,
          name: 'LGTM',
          condition: Plugin::Command[:CanReplyAll],
          visible: true,
          role: :timeline) do |opt|
    messages = opt.messages.map(&:message)
    t = Thread.new(&method(:get_image))
    t.join
    # Plugin.call(:openimg_open, @image) #Preview
    opt.widget.create_postbox(to: messages,
                              header: messages.map{|x| "@#{x.idname}"}.uniq.join(' ') + ' ',
                              footer: @image,
                              use_blind_footer: !UserConfig[:footer_exclude_reply]) end
end
