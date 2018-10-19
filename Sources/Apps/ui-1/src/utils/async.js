
export async function forEach(array, callback) {
  for (let index = 0; index < array.length; index++) {
    try {
      const res = await callback(array[index], index, array)
      if (res === false) {
        return
      }
    } catch(e) {
      throw e
    }
  }
}
