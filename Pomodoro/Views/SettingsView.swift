import SwiftUI

/// 設定画面
struct SettingsView: View {
    @ObservedObject var settings: PomodoroSettings
    @Environment(\.dismiss) private var dismiss
    @State private var soundOptions: [SoundManager.SoundOption] = []

    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("設定")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .focusEffectDisabled()
                .keyboardShortcut(.escape, modifiers: [])
                .accessibilityLabel("閉じる")
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()
                .opacity(0.5)

            ScrollView {
                VStack(spacing: 24) {
                    // 時間設定セクション
                    settingsSection(title: "時間設定", icon: "clock") {
                        DurationRow(
                            label: "集中時間",
                            value: $settings.focusDuration,
                            range: 1...120,
                            unit: "分"
                        )
                        DurationRow(
                            label: "短い休憩",
                            value: $settings.shortBreakDuration,
                            range: 1...60,
                            unit: "分"
                        )
                        DurationRow(
                            label: "長い休憩",
                            value: $settings.longBreakDuration,
                            range: 1...60,
                            unit: "分"
                        )
                        StepperRow(
                            label: "長い休憩までのセット数",
                            value: $settings.sessionsBeforeLongBreak,
                            range: 1...12
                        )
                    }

                    // 動作設定セクション
                    settingsSection(title: "動作", icon: "gearshape") {
                        ToggleRow(label: "通知", value: $settings.notificationsEnabled)
                        ToggleRow(label: "完了音", value: $settings.playSoundOnComplete)
                        ToggleRow(label: "自動で次セッション開始", value: $settings.autoStartNextSession)
                        ToggleRow(label: "メニューバーに表示", value: $settings.showInMenuBar)
                    }

                    settingsSection(title: "通知音", icon: "speaker.wave.2") {
                        ForEach(SessionType.allCases, id: \.self) { sessionType in
                            let suffix = sessionType == .focus ? "完了" : "終了"
                            SoundPickerRow(
                                label: "\(sessionType.displayName)\(suffix)",
                                selection: binding(for: sessionType),
                                options: soundOptions,
                                isEnabled: settings.playSoundOnComplete,
                                onPreview: { SoundManager.shared.playSound(id: settings.completionSoundID(for: sessionType)) }
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        Button("音源フォルダを開く") {
                            SoundManager.shared.openUserSoundsDirectory()
                        }
                        .buttonStyle(.link)

                        Button("一覧を更新") {
                            reloadSoundOptions()
                        }
                        .buttonStyle(.link)

                        Spacer()
                    }
                    .font(.system(size: 12))

                    // ショートカット情報
                    settingsSection(title: "キーボードショートカット", icon: "keyboard") {
                        ShortcutRow(label: "開始 / 一時停止", shortcut: "⌘ ↩")
                        ShortcutRow(label: "リセット", shortcut: "⌘ R")
                        ShortcutRow(label: "スキップ", shortcut: "⌘ →")
                        ShortcutRow(label: "設定", shortcut: "⌘ ,")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .frame(width: 440, height: 660)
        .background(
            VisualEffectBackground(material: .popover, blendingMode: .behindWindow)
        )
        .onAppear {
            reloadSoundOptions()
        }
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.primary.opacity(0.04))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func binding(for sessionType: SessionType) -> Binding<String> {
        Binding(
            get: { settings.completionSoundID(for: sessionType) },
            set: { settings.setCompletionSoundID($0, for: sessionType) }
        )
    }

    private func reloadSoundOptions() {
        let options = SoundManager.shared.availableSounds()
        soundOptions = options
        let validIDs = Set(options.map(\.id))
        for sessionType in SessionType.allCases {
            let currentID = settings.completionSoundID(for: sessionType)
            if !validIDs.contains(currentID) {
                let fallback = PomodoroSettings.defaultCompletionSoundID(for: sessionType)
                let nextID = validIDs.contains(fallback) ? fallback : SoundManager.SoundOption.systemDefaultID
                settings.setCompletionSoundID(nextID, for: sessionType)
            }
        }
    }
}

// MARK: - Setting Rows

/// 時間設定行
struct DurationRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            HStack(spacing: 4) {
                TextField("", value: $value, format: .number)
                    .textFieldStyle(.plain)
                    .frame(width: 40)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 13, weight: .medium, design: .rounded))

                Text(unit)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Stepper("", value: $value, in: range)
                    .labelsHidden()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)\(unit)")
    }
}

/// ステッパー行
struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            HStack(spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .frame(width: 24, alignment: .trailing)

                Stepper("", value: $value, in: range)
                    .labelsHidden()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)")
    }
}

/// トグル行
struct ToggleRow: View {
    let label: String
    @Binding var value: Bool

    var body: some View {
        Toggle(isOn: $value) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
        }
        .toggleStyle(.switch)
        .controlSize(.small)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

/// セッションごとの通知音選択行
struct SoundPickerRow: View {
    let label: String
    @Binding var selection: String
    let options: [SoundManager.SoundOption]
    let isEnabled: Bool
    let onPreview: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer(minLength: 12)

            Picker(label, selection: $selection) {
                ForEach(options) { option in
                    Text("\(option.displayName) (\(option.sourceLabel))")
                        .tag(option.id)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 210, alignment: .trailing)
            .disabled(!isEnabled)

            Button(action: onPreview) {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            .disabled(!isEnabled || selection == SoundManager.SoundOption.noneID)
            .help("この音を試聴")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

/// ショートカット表示行
struct ShortcutRow: View {
    let label: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.primary.opacity(0.06))
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView(settings: PomodoroSettings())
}
