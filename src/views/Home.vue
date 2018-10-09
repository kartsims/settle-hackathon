<script>
export default {
  created () {
    switch (this.$route.query.mode) {
      case 'work':
        return this.$router.push('/work')
    }
    // default
    this.$router.push('/work')
  }
}
</script>
