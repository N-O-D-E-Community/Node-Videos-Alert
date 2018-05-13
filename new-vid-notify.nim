import xmlparser
import xmltree
import httpclient
import streams
import strutils
import os
import json
import htmlparser
import streams

let tokenurl = ""
let file = "links.txt"

var
  client = newHttpClient()
  data = client.getContent("https://n-o-d-e.net/rss/rss.xml")
  xml : XmlNode = parseXML(newStringStream(data)).child("channel")
  itemsXML : seq[XmlNode] = xml.findAll("item")
let fsi = newFileStream(file, fmRead)
let savedLinks = fsi.readAll()
fsi.close()
var fso = newFileStream(file, fmWrite)
fso.write(savedLinks)
for i in 0..high(itemsXML):
  if itemsXML[i].child("link") != nil:
      let link = itemsXML[i].child("link").innerText
      if not savedLinks.contains(link):
        fso.write(link & "\n")
        if itemsXML[i].child("title") != nil:
          let title =  itemsXML[i].child("title").innerText
          var videoLinks = ""
          var youtubeLink = ""
          let html = parseHtml(client.getContent(link))
          for elem in html.findall("p"):
            if elem.attr("class") == "description":
              for a in elem.findall("a"):
                videolinks.add("**$1** $2\n" % [a.innerText, a.attr("href")])
                if a.innerText.contains("Youtube"):
                  youtubeLink = a.attr("href")
              client.headers = newHttpHeaders({ "Content-Type": "application/json" })
              let body = %*{
                  "username": "Node",
                  "avatar_url": "https://n-o-d-e.net/images/avatar.png",
                  "embeds": [{
                    "title": title,
                    "description": videolinks,
                    "url": link,
                    "color": 0xeeeeee,
                    "image": {
                      "url": "https://img.youtube.com/vi/" & youtubeLink.split("=")[1] & "/0.jpg"
                      }
                    }]
                  }
              echo body
              let response = client.request(tokenurl, httpMethod = HttpPost, body = $body)
              echo response.status
              echo response.body
              sleep(3000)
fso.close()
