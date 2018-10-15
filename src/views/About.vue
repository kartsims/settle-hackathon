<template>
  <div class="center">
    <h2>About</h2>
    <p>This app has been developed by Simon Tarchichi for <a href="http://settle.finance" target="_blank">settle.finance</a>.</p>
    <p>Request new features or share your feedback using the form below :</p>

    <div v-if="showConfirm" class="confirmation">
      Your message has been sent.
    </div>

    <form v-else @submit.prevent="submitForm">
      <label>
        Name :<br/>
        <input v-model="payload.name"/>
      </label>
      <label>
        Email :<br/>
        <input v-model="payload.email"/>
      </label>
      <label>
        Message :<br/>
        <textarea v-model="payload.message"/>
      </label>
      <button type="submit">SEND</button>
    </form>

  </div>
</template>

<script>
export default {
  data () {
    return {
      showConfirm: false,
      payload: {
        name: '',
        email: '',
        message: '',
      }
    }
  },
  methods: {
    submitForm () {
      const error = this.checkError()
      if (error) {
        alert(error)
        return
      }
      // TODO send this message
      console.log(JSON.stringify(this.payload, null, 2))
      this.showConfirm = true
    },
    checkError () {
      if (!this.payload.name) {
        return 'Name is required'
      }
      if (!this.payload.email) {
        return 'Email is required'
      }
      if (!this.payload.message) {
        return 'Message is required'
      }
      return false
    }
  }
}
</script>

<style lang="scss" scoped>
.center {
  text-align: center;
}
h2 {
  margin-top: 20px;
  margin-bottom: 40px;
}
form {
  width: 400px;
  margin: 40px auto 0;
  text-align: left;
  input, textarea {
    width: 100%;
    font-size: 16px;
    font-family: inherit;
    padding: 10px;
  }
  textarea {
    background: transparent;
    height: 120px;
    border: 1px solid #2c3e50;
    margin-top: 10px;
    color: #ffffffc2;
  }
  button {
    width: 100%;
    border: none;
    border-radius: 5px;
    padding: 10px 0;
    font-size: 14px;
    color: #2c3e50;
    font-weight: bold;
    background: #f6a622;
  }
}
label {
  display: block;
  padding-bottom: 30px;
  font-size: 14px;
  font-weight: bold;
}
.confirmation {
  font-size: 18px;
  font-style: italic;
  color: #f6a622;
  padding: 40px 0;
}
</style>
