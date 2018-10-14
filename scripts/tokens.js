// const request = require('async-request')
const request = require('request-promise-native')
const cheerio = require('cheerio')
const fs = require('fs')
const path = require('path')
const async = require('./utils/async')

const config = require('../config.json')

const tokensFilePath = path.resolve(__dirname, '../src/assets/tokens.json')
const tokens = require(tokensFilePath)
const tokensAbiFilePath = path.resolve(__dirname, '../src/assets/tokensAbi.json')
const tokensAbi = require(tokensAbiFilePath)

const sleep = delay => new Promise(resolve => setTimeout(resolve, delay));


console.log('%d tokens found already', tokens.length)

async function getTokens () {
  for (let page = 1; page <= 15; page++) {
    try {
      const body = await request('https://etherscan.io/tokens?p=' + page)
  
      const $ = await cheerio.load(body)
      
      await async.forEach($('.table-striped').find('.hidden-xs h5'), async (el) => {
        const token = {
          address: null,
          name: null,
          ticker: null,
        }
        const matches = $(el).text().match(/(.*) \((.*)\)/)
        token.name = matches[1]
        token.ticker = matches[2]
        token.address = $(el).find('a').attr('href').replace(/^.*0x/, '0x')
        await addToken(token)
      })
  
    } catch (e) {
      console.error(e)
    }
  }
  try {
    console.log('%d tokens', tokens.length)
    fs.writeFileSync(tokensFilePath, JSON.stringify(tokens, null, 2))
    fs.writeFileSync(tokensAbiFilePath, JSON.stringify(tokensAbi, null, 2))
  } catch (e) {
    console.error(e)
  }
}

async function addToken(token) {
  await addTokenAbi(token)
  if (tokens.find(i => i.address === token.address)) {
    console.log('%s [%s] exists already!', token.name, token.ticker)
    return
  }
  console.log('Adding %s [%s]', token.name, token.ticker)
  tokens.push(token)
}

async function addTokenAbi(token) {
  if (tokensAbi[token.address]) {
    console.log("%s [%s] ABI exists already", token.name, token.ticker)
    return
  }
  try {
    const tokenAbi = await request('https://api.etherscan.io/api', {
      qs: {
        module: 'contract',
        action: 'getabi',
        address: token.address,
        apikey: config.etherscanApiKey,
      }
    })
    tokensAbi[token.address] = JSON.parse(JSON.parse(tokenAbi).result)
    console.log("%s [%s] ABI found", token.name, token.ticker)

  } catch(e) {
    console.log('%s [%s] token API retrieval failed', token.name, token.ticker)
  }
}

getTokens()
