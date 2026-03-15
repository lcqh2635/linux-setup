# linux-setup

# 在命令行创建新仓库
echo "# linux-setup" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/lcqh2635/linux-setup.git
git push -u origin main

# 从命令行推送现有仓库
git remote add origin https://github.com/lcqh2635/linux-setup.git
git branch -M main
git push -u origin main
