import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/yielder
import gleam_community/maths/elementary.{pi, sin}
import gleam_community/maths/piecewise
import gleam_community/maths/sequences

pub fn main() {
  let amplitude = 5.0
  let samples_per_period = 16
  let initial_phase = 0.0

  square(amplitude:, samples_per_period:, initial_phase:)
  |> take(2 * samples_per_period)
  |> to_list
  |> list.try_map(fn(a) { a |> piecewise.round(Some(5), None) })
  |> io.debug
}

// pub fn sine_from_frequency(
//   amplitude: Float,
//   frequency: Float,
//   sample_rate: Float,
//   initial_phase: Float,
// ) -> yielder.Yielder(Float) {
//   let samples_per_period = sample_rate /. frequency
//   sine(amplitude, samples_per_period, initial_phase)
// }

// pub fn sine(
//   amplitude amplitude: Float,
//   samples_per_period samples_per_period: Float,
//   initial_phase initial_phase: Float,
// ) -> yielder.Yielder(Float) {
//   let assert Ok(t) =
//     sequences.linear_space(
//       0.0,
//       2.0 *. pi(),
//       float.truncate(samples_per_period),
//       False,
//     )
//   let waveform = t |> list.map(fn(x) { amplitude *. sin(x +. initial_phase) })

//   yielder.from_list(waveform) |> yielder.cycle
// }

pub fn sine(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  initial_phase initial_phase: Float,
) -> yielder.Yielder(Float) {
  n(samples_per_period, initial_phase, fn(sample) {
    amplitude *. sin(sample +. initial_phase)
  })
}

pub fn square(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  initial_phase initial_phase: Float,
) -> yielder.Yielder(Float) {
  n(samples_per_period, initial_phase, fn(_) { amplitude +. initial_phase })
}

// TODO: Rename
fn n(
  samples_per_period samples_per_period: Int,
  initial_phase initial_phase: Float,
  transform transform: fn(Float) -> Float,
) {
  // let phase_shift = initial_phase /. { 2.0 *. pi() }
  let angles = sequences.linear_space(0.0, pi(), samples_per_period / 2, False)

  case angles {
    Error(_) -> yielder.from_list([])
    Ok(angles) -> {
      let half_cycle =
        angles
        |> list.map(transform)
        |> yielder.from_list

      // let half_cycle =
      //   half_cycle
      //   |> yielder.drop(float.truncate(
      //     phase_shift *. int.to_float(samples_per_period),
      //   ))

      let negated_half_cycle =
        half_cycle
        |> yielder.map(fn(sample) {
          case sample {
            0.0 -> 0.0
            _ -> -1.0 *. sample
          }
        })

      half_cycle |> yielder.append(negated_half_cycle) |> yielder.cycle
    }
  }
}

// pub fn square(
//   amplitude amplitude: Float,
//   samples_per_period samples_per_period: Int,
//   initial_phase initial_phase: Float,
// ) -> yielder.Yielder(Float) {
//   let half_period = samples_per_period / 2
//   let positive = yielder.repeat(amplitude, half_period)
//   let negative = yielder.repeat(-amplitude, half_period)

//   let full_cycle = positive |> yielder.append(negative)

//   // Apply initial phase
//   let phase_samples =
//     int.floor(
//       initial_phase /. { 2.0 *. pi() } *. int.to_float(samples_per_period),
//     )
//   let rotated_cycle =
//     full_cycle
//     |> yielder.drop(phase_samples)
//     |> yielder.append(full_cycle |> yielder.take(phase_samples))

//   rotated_cycle |> yielder.cycle
// }

// pub fn sine(
//   amplitude: Float,
//   samples_per_period: Int,
//   initial_phase: Float,
// ) -> yielder.Yielder(Float) {
//   let quarter_samples = float.floor(samples_per_period /. 4.0)
//   let half_pi = pi() /. 2.0

//   // Generate the four quadrants
//   let assert Ok(q1) =
//     sequences.linear_space(0.0, half_pi, float.truncate(quarter_samples), False)
//   let assert Ok(q2) =
//     sequences.linear_space(
//       half_pi,
//       pi(),
//       float.truncate(quarter_samples),
//       False,
//     )
//   let assert Ok(q3) =
//     sequences.linear_space(
//       pi(),
//       1.5 *. pi(),
//       float.truncate(quarter_samples),
//       False,
//     )
//   let assert Ok(q4) =
//     sequences.linear_space(
//       1.5 *. pi(),
//       2.0 *. pi(),
//       float.truncate(quarter_samples +. 1.0),
//       True,
//     )

//   // Combine quadrants and apply sine function
//   let waveform =
//     list.flatten([q1, q2, q3, q4])
//     |> list.map(fn(phase) { amplitude *. sin(phase +. initial_phase) })

//   yielder.from_list(waveform) |> yielder.cycle
// }

pub fn take(yielder: yielder.Yielder(Float), n: Int) -> yielder.Yielder(Float) {
  yielder |> yielder.take(n)
}

pub fn append(
  yielder_1: yielder.Yielder(Float),
  yielder_2: yielder.Yielder(Float),
) -> yielder.Yielder(Float) {
  yielder_1 |> yielder.append(yielder_2)
}

pub fn prepend(
  yielder_1: yielder.Yielder(Float),
  yielder_2: yielder.Yielder(Float),
) -> yielder.Yielder(Float) {
  yielder_2 |> yielder.append(yielder_1)
}

pub fn to_list(yielder: yielder.Yielder(Float)) -> List(Float) {
  yielder |> yielder.to_list
}
// TODO: Round

// TODO: make sure amplitudes are hit perfectly?
// todo
// TODo: with sample index

// TODO: safe and unsafe versions, where safe always hits the amplitude and 0 exactly
// TODO: test 0, 1, 2, 4, 8 samples, etc
// TODO: Birdie
// TODO: Labels

// 1. Square Wave: Alternates between two fixed values.
// 2. Sawtooth Wave: Ramps up linearly and then drops sharply.
// 3. Triangle Wave: Ramps up linearly, then down linearly.
// 4. Pulse Wave: Similar to square wave but with adjustable duty cycle.
// 5. White Noise: Random signal with constant power spectral density.
// 6. Pink Noise: Noise with power spectral density inversely proportional to frequency.
// 7. Brown Noise: Noise with power spectral density inversely proportional to frequency squared.
// 8. Chirp: A signal that increases or decreases in frequency over time.
// 9. AM (Amplitude Modulated) Signal: A carrier signal modulated by another signal.
// 10. FM (Frequency Modulated) Signal: A carrier signal whose frequency is modulated by another signal.
// 11. Impulse: A signal that is zero everywhere except for a single point.
// 12. Step Function: A signal that changes from one constant level to another instantaneously.
// 13. Ramp Function: A signal that increases linearly with time.
// 14. Exponential Decay: A signal that decays exponentially over time.
// 15. Gaussian Pulse: A pulse shaped like a Gaussian distribution.
// 16. Sinc Function: The sine cardinal function, often used in signal processing.
// 17. Harmonics: Multiples of a fundamental frequency combined to create complex waveforms.
// 18. LFO (Low Frequency Oscillator): Very low frequency signals often used for modulation.
