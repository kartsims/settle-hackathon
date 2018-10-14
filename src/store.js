import Vue from 'vue'
import Vuex from 'vuex'

import moment from 'moment'
import store from 'store'
import request from 'request-promise-native'

import tokens from '@/assets/tokens.json'
import config from '../config.json'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    tokens,
    blockNumber: store.get('blockNumber', 0),
    watchList: store.get('watchList', []),
    txs: store.get('txs', []),
  },
  mutations: {
    WATCHLIST_ADD (state, payload) {
      if (state.watchList.findIndex(i => {
        return i.tokenAddress === payload.tokenAddress && i.address === payload.address
      }) !== -1) {
        console.log('Already exists')
        return
      }
      state.watchList.push(payload)
      store.set('watchList', state.watchList)
    },
    TX_ACCOUNT_SET (state, payload) {
      state.txs = state.txs.filter(tx => {
        return tx.tokenAddress !== payload.tokenAddress || tx.address !== payload.address
      }).concat(payload.txs).sort((a, b) => {
        return a.timestamp < b.timestamp ? 1 : -1
      })
      store.set('txs', state.txs)
    },
    WATCHLIST_TX_LOADED (state, payload) {
      const index = state.watchList.findIndex(i => {
        return i.tokenAddress === payload.tokenAddress && i.address === payload.address
      })
      if (index === -1) {
        return
      }
      state.watchList[index].txLoaded = payload.value
      store.set('watchList', state.watchList)
    },
  },
  actions: {
    async getTxs({ commit }, payload) {
      console.log('getTxs', JSON.stringify(payload, null, 2))
      let txs = []
      let timestamp = +moment().format('X')
      const minTimestamp = +moment().subtract(config.txHistoryDays, 'days').format('X')
      try {
        const result = await request('https://api.etherscan.io/api', {
          qs: {
            module: 'account',
            action: 'tokentx',
            contractaddress: payload.tokenAddress,
            address: payload.address,
            apikey: config.etherscanApiKey,
            page: 1,
            offset: config.txHistoryMax,
            sort: 'desc',
          }
        })
        JSON.parse(result).result.forEach(tx => {
          timestamp = +tx.timeStamp
          if (timestamp < minTimestamp) {
            return
          }
          const result = {
            timestamp,
            tokenAddress: payload.tokenAddress,
            address: payload.address,
            otherAddress: tx.from,
            value: tx.value / Math.pow(10, tx.tokenDecimal),
            hash: tx.hash,
            blockNumber: +tx.blockNumber,
          }
          if (tx.from === payload.address) {
            result.otherAddress = tx.to
            result.value = -result.value
          }
          txs.push(result)
        })
        const txLoaded = txs.length < config.txHistoryMax
        if (txLoaded) {
          commit('TX_ACCOUNT_SET', {
            ...payload,
            txs
          })
        }
        commit('WATCHLIST_TX_LOADED', {
          ...payload,
          value: txLoaded,
        })
        console.log('%d txs found', txs.length)
      } catch(e) {
        console.log('tx retrieval failed')
        console.log(e)
      }
    },
  },
  getters: {
    getToken: (state) => (address) => {
      return state.tokens.find(token => token.address === address)
    },
  }
})
