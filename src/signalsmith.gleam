import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/yielder
import gleam_community/maths/elementary.{pi, sin}
import gleam_community/maths/piecewise
import gleam_community/maths/sequences

pub type Phase {
  Zero
  Ninety
  OneEighty
  TwoSeventy
}

pub fn main() {
  let amplitude = 5.0
  let samples_per_period = 16

  triangle(amplitude:, samples_per_period:, phase: Zero)
  |> take(2 * samples_per_period)
  |> to_list
  |> list.try_map(fn(a) { a |> piecewise.round(Some(5), None) })
  |> io.debug
}

pub fn sine(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  phase phase: Phase,
) -> yielder.Yielder(Float) {
  n(amplitude:, samples_per_period:, phase:, transform: sin)
}

pub fn cosine(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  phase phase: Phase,
) -> yielder.Yielder(Float) {
  let phase = add_phase(phase, Ninety)
  n(amplitude:, samples_per_period:, phase: phase, transform: sin)
}

pub fn square(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  phase phase: Phase,
) -> yielder.Yielder(Float) {
  n(amplitude:, samples_per_period:, phase:, transform: fn(_) { amplitude })
}

pub fn triangle(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  phase phase: Phase,
) -> yielder.Yielder(Float) {
  n(amplitude:, samples_per_period:, phase:, transform: fn(x) {
    let normalized_x = x /. pi()
    case normalized_x <. 0.5 {
      True -> 4.0 *. normalized_x -. 1.0
      False -> -4.0 *. normalized_x +. 3.0
    }
  })
}

fn phase_value(phase: Phase) -> Int {
  case phase {
    Zero -> 0
    Ninety -> 1
    OneEighty -> 2
    TwoSeventy -> 3
  }
}

fn add_phase(phase_a: Phase, phase_b: Phase) -> Phase {
  let phase_a_value = phase_value(phase_a)
  let phase_b_value = phase_value(phase_b)
  let sum = phase_a_value + phase_b_value
  let result = sum % 4
  case result {
    0 -> Zero
    1 -> Ninety
    2 -> OneEighty
    _ -> TwoSeventy
  }
}

// TODO: Rename
fn n(
  amplitude amplitude: Float,
  samples_per_period samples_per_period: Int,
  phase phase: Phase,
  transform transform: fn(Float) -> Float,
) {
  let angles = sequences.linear_space(0.0, pi(), samples_per_period / 2, False)

  case angles {
    Error(_) -> yielder.from_list([])
    Ok(angles) -> {
      let half_cycle =
        angles
        |> list.map(fn(sample) { amplitude *. transform(sample) })
        |> yielder.from_list

      let negated_half_cycle =
        half_cycle
        |> yielder.map(fn(sample) {
          case sample {
            0.0 -> 0.0
            _ -> -1.0 *. sample
          }
        })

      case phase {
        Zero ->
          half_cycle |> yielder.append(negated_half_cycle) |> yielder.cycle
        Ninety -> {
          let samples_to_drop = samples_per_period / 4
          half_cycle
          |> yielder.append(negated_half_cycle)
          |> yielder.cycle
          |> yielder.drop(samples_to_drop)
        }
        TwoSeventy ->
          negated_half_cycle
          |> yielder.append(half_cycle)
          |> yielder.cycle
        OneEighty ->
          negated_half_cycle
          |> yielder.append(half_cycle)
          |> yielder.cycle
      }
    }
  }
}

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

// 2. Sawtooth Wave: Ramps up linearly and then drops sharply.
// 3. Triangle Wave: Ramps up linearly, then down linearly.
// 4. Pulse Wave: Similar to square wave but with adjustable duty cycle.
// 5. White Noise: Random signal with constant power spectral density.
// 6. Pink Noise: Noise with power spectral density inversely proportional to frequency.
// 7. Brown Noise: Noise with power spectral density inversely proportional to frequency squared.
// ---
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
