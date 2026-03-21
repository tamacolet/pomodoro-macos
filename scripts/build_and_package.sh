#!/bin/bash
set -euo pipefail

# ================================================
#  ポモドーロ ビルド & パッケージスクリプト
# ================================================

APP_NAME="Pomodoro"
DISPLAY_NAME="ポモドーロ"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
DERIVED_DATA="${BUILD_DIR}/DerivedData"
APP_PATH="${DERIVED_DATA}/Build/Products/Release/${APP_NAME}.app"
DMG_STAGING="${BUILD_DIR}/dmg_staging"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"

echo "================================================"
echo "  ${DISPLAY_NAME} ビルド & パッケージスクリプト"
echo "================================================"

# クリーンアップ
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 1. Release ビルド
echo "[1/4] Release ビルド中..."
xcodebuild \
    -project "${PROJECT_DIR}/${APP_NAME}.xcodeproj" \
    -scheme "${APP_NAME}" \
    -configuration Release \
    -derivedDataPath "${DERIVED_DATA}" \
    -arch arm64 \
    -arch x86_64 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 | tail -5

if [ ! -d "${APP_PATH}" ]; then
    echo "  エラー: ビルドに失敗しました"
    exit 1
fi
echo "  ビルド成功: ${APP_PATH}"

# 2. Ad-hoc 署名
echo "[2/4] Ad-hoc 署名中..."
codesign --force --deep --sign - "${APP_PATH}"
echo "  署名完了"

# 3. DMG ステージング
echo "[3/4] アプリをコピー中..."
mkdir -p "${DMG_STAGING}"
cp -R "${APP_PATH}" "${DMG_STAGING}/"

# Applications シンボリックリンクを追加
ln -s /Applications "${DMG_STAGING}/Applications"

# 4. DMG 作成
echo "[4/4] DMG 作成中..."
rm -f "${DMG_PATH}"

if command -v create-dmg &>/dev/null; then
    create-dmg \
        --volname "${DISPLAY_NAME}" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "${APP_NAME}.app" 150 190 \
        --icon "Applications" 450 190 \
        --hide-extension "${APP_NAME}.app" \
        --app-drop-link 450 190 \
        "${DMG_PATH}" \
        "${DMG_STAGING}" || true
else
    echo "  create-dmg が見つかりません。hdiutil で作成します..."
    hdiutil create \
        -volname "${DISPLAY_NAME}" \
        -srcfolder "${DMG_STAGING}" \
        -ov \
        -format UDZO \
        "${DMG_PATH}"
fi

# クリーンアップ
rm -rf "${DMG_STAGING}"

echo ""
echo "================================================"
echo "  ビルド & パッケージ完了!"
echo "================================================"
echo "  .app : ${APP_PATH}"
echo "  .dmg : ${DMG_PATH}"
echo ""
echo "  配布方法:"
echo "    1. .dmg または .app を ZIP 圧縮して共有"
echo "    2. GitHub Releases にアップロード"
echo "    3. Google Drive / Dropbox で共有"
echo "  ※ 受け取った方の起動方法は README を参照してください"
