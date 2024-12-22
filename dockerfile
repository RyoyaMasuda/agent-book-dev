FROM python:3.10.12-slim-bookworm

# Pythonのパスにローカルユーザーのパス(~/.local/bin)を追加
ENV PATH="/root/.local/bin:${PATH}"

# sklearnの古いバージョンを無理やりインストールするための環境変数を設定
# 2024年9月18日以降、通常の方法ではsklearnをインストールできないため、この設定が必要
ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

# 必要なパッケージ（curl, unzip, sudo, git）をインストールし、キャッシュをクリアしてディスクスペースを節約
RUN apt-get update && apt-get install -y \
    curl unzip sudo git htop\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# rootユーザーのパスワードを設定
RUN echo "root:password" | chpasswd

# 非ルートユーザー(user)を作成し、sudo権限を付与
# userのパスワードを設定
# userをsudoグループに追加
RUN useradd -ms /bin/bash user \
    && echo "user:password" | chpasswd \  
    && usermod -aG sudo user               

# userにホームディレクトリの権限を与える
RUN chown -R user:user /home/user

# 非ルートユーザーのパスに~/.local/binを追加 (pipなどのグローバルパッケージを利用可能にする)
ENV PATH="/home/user/.local/bin:$PATH"

# 非ルートユーザーの.sshディレクトリに適切なパーミッションを設定
RUN mkdir -p /home/user/.ssh \
    && chmod 700 /home/user/.ssh

# 以降のコマンドは非ルートユーザー(user)として実行
USER user

# 古い依存関係リスト(requirements_old_image.txt)をイメージに追加
# ADD requirements.txt .

# 依存関係をpipでインストール
# RUN pip install -r requirements.txt