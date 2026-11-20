# BlissOS 16.9.7 for Lenovo ThinkBook 16p (2025 Ryzen Edition)

[![BlissOS](https://img.shields.io/badge/BlissOS-16.9.7%20(Android%2013)-blue)](https://blissos.org/)
[![Kernel](https://img.shields.io/badge/Kernel-6.12.77--zenith-green)](https://github.com/android-generic/kernel-zenith)
[![Secure Boot](https://img.shields.io/badge/UEFI%20Secure%20Boot-Supported%20(MOK)-brightgreen)](#安全启动配置--uefi-secure-boot-setup)

> 针对 **联想 ThinkBook 16p（2025 锐龙版）** 深度适配的 BlissOS 16.9.7（Android 13 + GApps）镜像与补丁说明。  
> Adapted BlissOS 16.9.7 (Android 13 + GApps) build with full hardware support for **Lenovo ThinkBook 16p (2025 Ryzen Edition)**.

---

## 🖥️ 已适配硬件 / Tested Hardware

| 组件 / Component | 型号 / Model | 状态 / Status |
| :--- | :--- | :--- |
| **CPU** | AMD Ryzen 9 8945HX (16C/32T) | ✅ 正常 / Working |
| **核显 / iGPU** | AMD Radeon 610M (`1002:164E`, `amdgpu`) | ✅ 硬件加速 / HW Accel |
| **独显 / dGPU** | NVIDIA GeForce RTX 5060 Laptop (`10DE:2D59`) | ℹ️ 已屏蔽 `nouveau` 避免冲突 / `nouveau` blocklisted |
| **Wi-Fi** | MediaTek Wi-Fi 7 MT7925 (`14C3:7925`, `mt7925e`) | ✅ 正常 / Working |
| **蓝牙 / Bluetooth** | MediaTek MT7925 Bluetooth (`0489:E111`, `btusb` + `btmtk`) | ✅ 正常 / Working |
| **安全启动 / Secure Boot** | UEFI Secure Boot (Microsoft Shim + MOK) | ✅ 正常 / Working |
| **启动方式 / Boot** | Ventoy / 直接刻录 U 盘 / 硬盘安装 | ✅ 正常 / Working |

---

## ✨ 修复与改进清单 / What's Fixed

1. **升级内核至 `6.12.77-zenith`（原生支持 MT7925）**
   - 原版 BlissOS 16.9.7 使用 `6.1.112-gloria` 内核，不包含 Linux 6.7+ 才合入主线的 `mt7925e` 无线驱动，且 `btusb` 缺少 `0489:e111`。
   - 基于官方 `android-generic/kernel-zenith` (`6.12` 分支) 编译了 `6.12.77-zenith` 内核与完整模块，集成 `mt7925e.ko`、`mt7925u.ko`、`btusb.ko`、`btmtk.ko`、`amdgpu.ko` 与 KernelSU。
   - 更新 `/system/vendor/firmware/mediatek/mt7925/` 下最新 Wi-Fi/蓝牙固件及 `regulatory.db`。
2. **修复联发科 MT7925 蓝牙（`0489:E111`）**
   - 在 `/system/etc/init.sh` 中自动加载 `btmtk` + `btusb`、设置 `/dev/rfkill` 权限并解除 rfkill 禁用。
   - 检测到联发科/内核 `hci0` 时自动启用 Linux 内核 HCI HAL（`btlinux-1.1`）替代不支持 MT7925 的用户态 `vbt` HAL，并修复 `do_bootcomplete` 中误禁用 `com.android.bluetooth` 的判断。
3. **修复 Linux 6.12 移除 `/dev/ashmem` 导致的黑屏与 App 闪退**
   - 开启 `sys.use_memfd=true` 使用 Linux 6.12 原生 `memfd_create`。
   - 对 64 位、32 位及 ARM64 的 `libcutils.so` 中的 `__has_memfd_support()` 进行补丁，跳过 `ro.vndk.version` 检查（避免在无 VNDK APEX 的 BlissOS 上触发 `libnativeloader.so` 寻找 `/apex/com.android.vndk.v33/etc/llndk.libraries.33.txt` 导致所有应用闪退）。
4. **修复 `amdgpu` 显卡初始化与 `modules.softdep`**
   - 移除 `modules.blocklist` 中对 `amdgpu` 的延迟屏蔽，并屏蔽 `nouveau`、`simpledrm` 等冲突驱动。
   - 修复 `modules.softdep` 中 11 处 3-token `softdep cifs` 语法问题，消除 Android `libmodprobe` 解析报错。
5. **修复 Ventoy 引导识别**
   - 在 `initrd.img` 中补齐 `/dev` 节点、`/scripts/00-ver` 中的 `# Bliss-OS` 标识及 `/dev/dm-*` 优先扫描逻辑。
6. **保留首次开机向导并开启“离线设置 / 跳过联网”**
   - 在 `build.prop` / `vendor/build.prop` 中配置 `ro.setupwizard.mode=OPTIONAL` 与 `ro.setupwizard.require_network=false`，可在 Wi-Fi 设置页面点击右下角 **`SET UP OFFLINE`（离线设置）** 跳过联网。
7. **支持 UEFI 安全启动（Secure Boot）**
   - 保留微软签名的 `BOOTx64.EFI`（Shim）与 `mmx64.efi`（MokManager），使用专用 MOK 密钥通过 `sbsign` 对 `/kernel` 和 `grubx64.efi`（含 `boot/grub/efi.img` 内部副本）完成签名，并附带公钥证书 `certs/BLISS_MOK.cer`。

---

## 📦 下载与合并 ISO / Download & Merge ISO

由于 GitHub Release 单文件上限为 **2 GB**，完整 ISO（约 2.8 GB）已拆分为两个分卷上传到 **[Releases](../../releases)**：

- `Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa`
- `Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab`
- `SHA256SUMS.txt`
- `BLISS_MOK.cer`

将两个分卷下载到同一目录后，放入对应平台的一键合并校验脚本直接运行即可：

| 平台 / Platform | 脚本文件 / Script | 使用方式 / Usage |
| :--- | :--- | :--- |
| **Windows (CMD)** | [`scripts/merge_iso.bat`](scripts/merge_iso.bat) | 放入分卷同目录后直接**双击运行**（自动合并 + SHA-256 校验） |
| **Windows (PowerShell)** | [`scripts/merge_iso.ps1`](scripts/merge_iso.ps1) | 放入分卷同目录，右键「使用 PowerShell 运行」或执行 `powershell -ExecutionPolicy Bypass -File .\merge_iso.ps1` |
| **Linux** | [`scripts/merge_iso_linux.sh`](scripts/merge_iso_linux.sh) | 放入分卷同目录后执行 `bash merge_iso_linux.sh` |
| **macOS** | [`scripts/merge_iso_macos.command`](scripts/merge_iso_macos.command) | 放入分卷同目录，在终端执行 `chmod +x merge_iso_macos.command` 后可在访达中直接**双击运行** |

也可手动运行命令合并：

### Windows (CMD)
```bat
copy /b Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partaa + Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.partab Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso
certutil -hashfile Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso SHA256
```

### Linux / macOS
```bash
cat Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso.part* > Bliss-v16.9.7-x86_64-ThinkBook16p-MT7925-k6.12.iso
sha256sum -c SHA256SUMS.txt   # macOS 请使用 shasum -a 256 -c SHA256SUMS.txt
```

---

## 🔐 安全启动配置 / UEFI Secure Boot Setup

如需在 **BIOS 开启 Secure Boot** 的情况下启动，只需在首次启动时导入一次 MOK 公钥证书（之后永久自动信任，无需再关安全启动）：

1. 将合并后的 ISO 放入 Ventoy U 盘的数据分区，同时将 `BLISS_MOK.cer` 复制到 Ventoy 的 **`VTOYEFI`**（FAT32）分区根目录（ISO 内部也已自带该证书）。
2. 开启 BIOS **Secure Boot**，从 U 盘启动。
3. 首次启动会进入蓝色界面的 **MOK Management**：
   - 选择 **`Enroll key from disk`** -> 选择 **`VTOYEFI`** 分区：
     - 如首次使用 Ventoy 安全启动，先导入 `ENROLL_THIS_KEY_IN_MOKMANAGER.cer`（`Continue` -> `Yes`）；
     - 再选择 **`Enroll key from disk`** -> 导入 **`BLISS_MOK.cer`**（`Continue` -> `Yes`）；
   - 选择 **`Reboot`** 重启即可正常引导进入 BlissOS。

---

## 🙏 致谢 / Credits

- [BlissOS](https://blissos.org/) — Android-x86 / BlissOS 16.9.7 base image
- [android-generic/kernel-zenith](https://github.com/android-generic/kernel-zenith) — Linux 6.12 kernel tree for Android-x86
- [linux-firmware](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/) — MediaTek MT7925 Wi-Fi & Bluetooth firmware
