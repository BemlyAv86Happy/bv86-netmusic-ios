//
//  PlaybackSettingsView.swift
//

import SwiftUI

struct PlaybackSettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager

    // 音质选项
    enum QualityOption: String, CaseIterable {
        case standard = "standard"
        case higher = "higher"
        case exhigh = "exhigh"
        case lossless = "lossless"
        case hires = "hires"
        case jyeffect = "jyeffect"
        case sky = "sky"
        case dolby = "dolby"
        case jymaster = "jymaster"

        var localizedKey: String {
            "settings.playback.qualityOptions.\(rawValue)"
        }
    }

    // 播放速率选项
    enum PlaybackRate: Double, CaseIterable, Identifiable {
        case half = 0.5
        case threeQuarters = 0.75
        case normal = 1.0
        case oneAndHalf = 1.5
        case oneAndThreeQuarters = 1.75
        case double = 2.0

        var id: Double { rawValue }

        var displayValue: String {
            "\(rawValue)x"
        }
    }

    // 状态变量
    @State private var selectedQuality: QualityOption = .exhigh
    @State private var selectedRate: PlaybackRate = .normal
    @State private var autoPlayEnabled: Bool = false
    @State private var lyricsEnabled: Bool = false

    var body: some View {
        Group {
            // MARK: - 音质设置
            SettingItemView(
                titleKey: "settings.playback.quality",
                descriptionKey: "settings.playback.qualityDesc",
                isScrambling: false
            ) {
                Menu {
                    ForEach(QualityOption.allCases, id: \.self) { option in
                        Button {
                            selectedQuality = option
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(option.localizedKey), bundle: localizationManager.bundle)
                                Spacer()
                                if selectedQuality == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text(LocalizedStringKey(selectedQuality.localizedKey), bundle: localizationManager.bundle)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }

            // MARK: - 播放速率设置
            SettingItemView(
                titleKey: "settings.playback.playbackRate",
                descriptionKey: "settings.playback.playbackRateDesc",
                isScrambling: false
            ) {
                Menu {
                    ForEach(PlaybackRate.allCases) { rate in
                        Button {
                            selectedRate = rate
                        } label: {
                            HStack {
                                Text(rate.displayValue)
                                Spacer()
                                if selectedRate == rate {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text(selectedRate.displayValue)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }

            // MARK: - 自动播放
            SettingItemView(
                titleKey: "settings.playback.autoPlay",
                descriptionKey: "settings.playback.autoPlayDesc",
                isScrambling: false
            ) {
                Toggle(isOn: $autoPlayEnabled) {
                    EmptyView()
                }
                .labelsHidden()
            }

            // MARK: - 缓存设置
            SettingItemView(
                titleKey: "settings.playback.cache",
                descriptionKey: "settings.playback.cacheDesc",
                isScrambling: false
            ) {
                Button(action: {
                    // 缓存设置操作
                }) {
                    Text("管理缓存")
                        .foregroundColor(.accentColor)
                }
            }

            // MARK: - 桌面歌词
            SettingItemView(
                titleKey: "settings.playback.lyrics",
                descriptionKey: "settings.playback.lyricsDesc",
                isScrambling: false
            ) {
                Toggle(isOn: $lyricsEnabled) {
                    EmptyView()
                }
                .labelsHidden()
            }
        }
    }
}

// 预览
struct PlaybackSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PlaybackSettingsView()
                .environmentObject(LocalizationManager())
        }
        .previewLayout(.sizeThatFits)
    }
}