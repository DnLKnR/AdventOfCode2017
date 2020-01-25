import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.ListBuffer
import scala.collection.mutable.MutableList

object Day17 {
  def main(args: Array[String]) {
    for (i <- 1 to 2017) {
      Spinlock.Spin(328)
    }
    println(CircularBuffer.GetSliceAt(0, 7).toString())

    Spinlock.Reset()

    for (i <- 1 to 50000000) {
      Spinlock.PseudoSpin(328)
    }
    println(PseudoBuffer.Buffer.toString())

  }

}

object Spinlock {
  var value = 1

  def Spin(steps: Int) {
    CircularBuffer.ForwardInsert(steps, this.value)
    this.value = this.value + 1
  }

  def PseudoSpin(steps: Int) {
    PseudoBuffer.ForwardInsert(steps, this.value)
    this.value = this.value + 1
  }

  def Reset() {
    this.value = 1
  }
}

object PseudoBuffer {
  var Buffer = ArrayBuffer(0, 0, 0)
  var Index = 0
  var Length = 1

  private var position = 0

  def ForwardInsert(steps: Int, value: Int) {
    this.position = (this.position + steps + 1) % this.Length

    if (this.position == this.Index) {
      this.Buffer.update(0, value)
    }
    if (this.Index + 1 >= this.Length && this.position == 0 || this.position == this.Index + 1) {
      this.Buffer.update(2, value)
    }

    if (this.position <= this.Index) {
      this.Index += 1
    }

    this.Length += 1
  }
}

object CircularBuffer {
  var Buffer = ListBuffer(0)

  private var position = 0

  def ForwardInsert(steps: Int, value: Int) {
    this.position = (this.position + steps + 1) % this.Buffer.length
    //this.Insert(this.position, value)
    this.Buffer.insert(this.position + 1, value)
  }

  def Insert(index: Int, value: Int) = {
    val (front, back) = this.Buffer.splitAt(index)
    this.Buffer = front ++ List(value) ++ back
  }

  def GetSliceAt(value: Int, size: Int): ListBuffer[Int] = {
    val index = this.Buffer.indexOf(value)
    val distance = size / 2
    val back = this.Slice(index + 1, index + distance + 1)
    val front = this.Slice(index - distance, index)
    return front ++ List(value) ++ back
  }

  def Slice(from: Int, until: Int): ListBuffer[Int] = {
    var start = from
    var end = until

    if (start < 0) {
      start += this.Buffer.length
    }
    start %= this.Buffer.length
    end %= this.Buffer.length

    if (start < end) {
      return this.Buffer.slice(start, end)
    }
    else {
      return this.Buffer.slice(start, this.Buffer.length) ++ this.Buffer.slice(0, end)
    }
  }
}