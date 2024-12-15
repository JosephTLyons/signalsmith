import gleeunit
import gleeunit/should
import signalsmith.{sine, square, take, to_list}

pub fn main() {
  gleeunit.main()
}

// ------------------ Sine

pub fn sine_should_fail_test() {
  sine(amplitude: 50.0, samples_per_period: -4, initial_phase: 0.0)
  |> to_list
  |> should.equal([])
}

pub fn sine_4_test() {
  let samples =
    sine(amplitude: 50.0, samples_per_period: 4, initial_phase: 0.0)
    |> take(4)
    |> to_list

  samples |> should.equal([0.0, 50.0, 0.0, -50.0])
}

// Better testing than this.. but how? 🤔
pub fn sine_8_test() {
  let samples =
    sine(amplitude: 50.0, samples_per_period: 8, initial_phase: 0.0)
    |> take(8)
    |> to_list

  let assert [0.0, a, 50.0, b, 0.0, c, -50.0, d] = samples

  { a >. 0.0 && a <. 50.0 } |> should.be_true()
  { b >. 0.0 && b <. 50.0 } |> should.be_true()
  { c >. -50.0 && c <. 0.0 } |> should.be_true()
  { d >. -50.0 && d <. 0.0 } |> should.be_true()
}

// ------------------ Square

pub fn square_4_no_amplitude_test() {
  square(amplitude: 0.0, samples_per_period: 2, initial_phase: 0.0)
  |> take(4)
  |> to_list
  |> should.equal([0.0, 0.0, 0.0, 0.0])
}

pub fn square_4_test() {
  square(amplitude: 1.0, samples_per_period: 2, initial_phase: 0.0)
  |> take(4)
  |> to_list
  |> should.equal([1.0, -1.0, 1.0, -1.0])
}
// pub fn square_4_inverted_phase_test() {
//   square(amplitude: 1.0, samples_per_period: 2, initial_phase: 190.0)
//   |> take(4)
//   |> to_list
//   |> should.equal([-1.0, 1.0, -1.0, 1.0])
// }
// Test with odd sample count
//    Should we allow it or force certain number of samples such that the polling is nice numbers?
