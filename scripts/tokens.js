const request = require('async-request')
const cheerio = require('cheerio')
const fs = require('fs')
const path = require('path')

const tokensFilePath = path.resolve(__dirname, '../src/assets/tokens.json')
const tokens = require(tokensFilePath)

console.log('%d tokens found already', tokens.length)

async function getTokens () {
  for (let page = 1; page <= 15; page++) {
    try {
      const { body } = await request('https://etherscan.io/tokens?p=' + page)
  
      const $ = await cheerio.load(body)
  
      $('.table-striped').find('.hidden-xs h5').each((i,el) => {
        const token = {
          address: null,
          name: null,
          ticker: null,
        }
        const matches = $(el).text().match(/(.*) \((.*)\)/)
        token.name = matches[1]
        token.ticker = matches[2]
        token.address = $(el).find('a').attr('href').replace(/^.*0x/, '0x')
        addToken(token)
      })
  
    } catch (e) {
      console.error(e)
    }
  }
  try {
    fs.writeFileSync(tokensFilePath, JSON.stringify(tokens, null, 2))
  } catch (e) {
    console.error(e)
  }
}

function addToken(token) {
  if (tokens.find(i => i.address === token.address)) {
    console.log('%s [%s] exists already!', token.name, token.ticker)
    return
  }
  console.log('Adding %s [%s]', token.name, token.ticker)
  tokens.push(token)
}

getTokens()
