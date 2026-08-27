import SwiftUI
import AVFoundation

struct Flashcard: Identifiable {
    let id = UUID()
    let spanish: String
    let spanishSentence: String
    let polish: String
    let polishSentence: String
}

struct ContentView: View {
    private let cards: [Flashcard] = [
        Flashcard(
            spanish: "aprender",
            spanishSentence: "Quiero aprender español.",
            polish: "uczyć się",
            polishSentence: "Chcę uczyć się hiszpańskiego."
        ),
        Flashcard(
            spanish: "trabajo",
            spanishSentence: "Tengo mucho trabajo hoy.",
            polish: "praca",
            polishSentence: "Mam dziś dużo pracy."
        ),
        Flashcard(
            spanish: "hablar",
            spanishSentence: "Me gusta hablar español.",
            polish: "mówić / rozmawiać",
            polishSentence: "Lubię mówić po hiszpańsku."
        ),
        Flashcard(
            spanish: "viaje",
            spanishSentence: "El viaje fue muy interesante.",
            polish: "podróż",
            polishSentence: "Podróż była bardzo interesująca."
        )
    ]

    @State private var index = 0
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    @State private var speaker = SpeechManager()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Apka Fiszki")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)

                Text("\(index + 1) / \(cards.count)")
                    .foregroundStyle(.secondary)

                Spacer()

                FlashcardView(
                    card: cards[index],
                    isFlipped: $isFlipped,
                    rotation: $rotation
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.55)) {
                        rotation += 180
                    }
                    isFlipped.toggle()
                }

                Button {
                    speaker.speak(cards[index].spanish)
                } label: {
                    Label("Posłuchaj wymowy", systemImage: "speaker.wave.2.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        previousCard()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .disabled(index == 0)

                    Button {
                        nextCard()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .disabled(index == cards.count - 1)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private func nextCard() {
        guard index < cards.count - 1 else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            index += 1
            resetCard()
        }
    }

    private func previousCard() {
        guard index > 0 else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            index -= 1
            resetCard()
        }
    }

    private func resetCard() {
        isFlipped = false
        rotation = 0
    }
}

struct FlashcardView: View {
    let card: Flashcard
    @Binding var isFlipped: Bool
    @Binding var rotation: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(.background)
                .shadow(radius: 12)

            if !isFlipped {
                VStack(spacing: 20) {
                    Text(card.spanish)
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(card.spanishSentence)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    Text("Dotknij karty, aby odwrócić")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding(30)
            } else {
                VStack(spacing: 20) {
                    Text(card.polish)
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(card.polishSentence)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    Text("Dotknij karty, aby wrócić")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                .padding(30)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .padding(.horizontal, 20)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
    }
}

@MainActor
final class SpeechManager {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        utterance.rate = 0.48

        synthesizer.speak(utterance)
    }
}

#Preview {
    ContentView()
}
