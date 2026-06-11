#!/bin/bash
# ============================================================
# かに風味ブログ 画像ダウンロードスクリプト
# GitHub にアップする前にこのスクリプトを実行してください
#
# 使い方:
#   chmod +x download_images.sh
#   ./download_images.sh
#
# 必要なコマンド: curl, awk
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="$SCRIPT_DIR/images"
URL_LIST="$SCRIPT_DIR/image_urls.txt"

mkdir -p "$IMAGES_DIR"

if [ ! -f "$URL_LIST" ]; then
  echo "ERROR: image_urls.txt が見つかりません"
  exit 1
fi

TOTAL=$(wc -l < "$URL_LIST" | tr -d ' ')
COUNT=0
SUCCESS=0
FAIL=0
SKIP=0

echo "================================================"
echo "  かに風味ブログ 画像ダウンロード"
echo "  対象: $TOTAL 枚"
echo "  保存先: $IMAGES_DIR"
echo "================================================"
echo ""

while IFS= read -r url || [ -n "$url" ]; do
  [ -z "$url" ] && continue

  FILENAME=$(basename "$url")
  DEST="$IMAGES_DIR/$FILENAME"
  COUNT=$((COUNT + 1))

  # すでにダウンロード済みならスキップ
  if [ -f "$DEST" ] && [ -s "$DEST" ]; then
    SKIP=$((SKIP + 1))
    continue
  fi

  printf "[%d/%d] %s ... " "$COUNT" "$TOTAL" "$FILENAME"

  HTTP_CODE=$(curl -s -o "$DEST" -w "%{http_code}" \
    --max-time 30 \
    --retry 3 \
    --retry-delay 2 \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -H "Referer: https://kaniaji.blog.fc2.com/" \
    "$url")

  if [ "$HTTP_CODE" = "200" ] && [ -s "$DEST" ]; then
    echo "OK"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "FAIL (HTTP $HTTP_CODE)"
    rm -f "$DEST"
    FAIL=$((FAIL + 1))
    # ログに記録
    echo "$url" >> "$SCRIPT_DIR/download_failed.txt"
  fi

  # サーバー負荷軽減のため少し待つ
  sleep 0.3

done < "$URL_LIST"

echo ""
echo "================================================"
echo "  完了!"
echo "  成功: $SUCCESS 枚"
echo "  スキップ(既存): $SKIP 枚"
echo "  失敗: $FAIL 枚"
if [ -f "$SCRIPT_DIR/download_failed.txt" ]; then
  echo "  失敗URLは download_failed.txt を確認してください"
fi
echo "================================================"
