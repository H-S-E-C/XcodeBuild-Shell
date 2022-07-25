#!/bin/sh
# 1、权限命令：chmod 777 XXX.sh
# 2、cocoapods 使用 workspace 形式

##手动配置参数

echo "\033[;32m input Project name： \033[0m"
read projectName
if [[ $projectName ]]; then
    PROJECT_NAME=$projectName
else
    read projectName
fi

echo "\033[;32m input Scheme name： \033[0m"
read schemeName
if [[ $schemeName ]]; then
    SCHEME_NAME=$schemeName
else
    read schemeName
fi

echo "\033[;32m input Target name： \033[0m"
read targetName
if [[ $targetName ]]; then
    TARGET_NAME=$targetName
else
    read targetName
fi

echo "\033[;32m input build type  0 Debug 1 Release 3 Other \033[0m"
read typeNumber
while([ $typeNumber != 0 ] && [ $typeNumber != 1 ] && [ $typeNumber != 3 ])
do
    echo "\033[;31m please input 0 or 1 or 3 \033[0m"
    read typeNumber
done
    
if [ $typeNumber == 0 ]; then
    BUILD_TYPE=Debug
elif [[ $typeNumber == 1 ]]; then
    BUILD_TYPE=Release
elif [[ $typeNumber == 3 ]]; then
    echo "\033[;43m 请输入自定义 build type \033[0m"
    read customeBuildType
    if [[ $customeBuildType ]]; then
        TARGET_NAME=$targetName
    else
        read customeBuildType
    fi
fi

BASE_PATH=$(cd `dirname $0`; pwd)

echo "\033[;32m 输入打包所需ExportOptions.plist的文件路径，或直接拖入窗口：空，为默认根目录 \033[0m"
read ExportOptionsPlist
if [[ $ExportOptionsPlist ]]; then
    EXPORTOPTIONSPLIST_PATH=$ExportOptionsPlist
else
    EXPORTOPTIONSPLIST_PATH=${BASE_PATH}/ExportOptions.plist
fi

## 项目根路径，xcodeproj/xcworkspace所在路径
PROJECT_ROOT_PATH=${BASE_PATH}
## 打包生成路径
PRODUCT_PATH=${BASE_PATH}/Package

echo "-------Setting End-------"

WORKSPACE_PATH=${PROJECT_ROOT_PATH}/${PROJECT_NAME}.xcworkspace
PROJECT_PATH=${PROJECT_ROOT_PATH}/${PROJECT_NAME}.xcodeproj

## if project
# xcodebuild clean -project ${PROJECT_PATH} -scheme ${SCHEME_NAME} -configuration ${BUILD_TYPE} || exit

## if workspace
xcodebuild clean -workspace ${WORKSPACE_PATH} -scheme ${SCHEME_NAME} -configuration ${BUILD_TYPE} || exit

echo "-------Build Clean End-------"

#Version
VERSION_NUMBER=`sed -n '/MARKETING_VERSION = /{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ${PROJECT_PATH}/project.pbxproj`
#build
BUILD_NUMBER=`sed -n '/CURRENT_PROJECT_VERSION = /{s/CURRENT_PROJECT_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ${PROJECT_PATH}/project.pbxproj`

BUILD_START_DATE="$(date +'%Y-%m-%d_%H-%M')"

## IPA 目录路径
IPA_DIR_NAME=${VERSION_NUMBER}_${BUILD_NUMBER}_${BUILD_START_DATE}

##xcarchive文件的存放路径
ARCHIVE_PATH=${PRODUCT_PATH}/IPA/${IPA_DIR_NAME}/${SCHEME_NAME}.xcarchive

## ipa文件的存放路径
IPA_PATH=${PRODUCT_PATH}/IPA/${IPA_DIR_NAME}

# 读取钥匙串证书 XXX 密码
#security unlock-keychain -p XXX
security unlock-keychain

echo  "-------Build Archive Begin-------"

## if project
# xcodebuild archive -project ${PROJECT_PATH} -scheme ${SCHEME_NAME} -archivePath ${ARCHIVE_PATH} -quiet || exit

## if workspace
xcodebuild archive -workspace ${WORKSPACE_PATH} -scheme ${SCHEME_NAME} -archivePath ${ARCHIVE_PATH} -quiet || exit

echo "-------Build Archive Success-------"


echo "-------Export IPA Begin-------"

xcodebuild -exportArchive -archivePath $ARCHIVE_PATH -exportPath ${IPA_PATH} -exportOptionsPlist ${EXPORTOPTIONSPLIST_PATH} -quiet || exit
echo ${IPA_PATH}/

if [ -e ${IPA_PATH}/${TARGET_NAME}.ipa ]; then
    echo "-------是否保留Archive文件-------"
    echo "\033[;32m 0删除 \033[0m 1保留 "

    read number
    while([[ $number != 0 ]] && [[ $number != 1 ]])
    do
        echo "\033[;31m please input 0 or 1 \033[0m"
        read number
    done
    
    if [ $number == 0 ]; then
        # 删除 Archive 文件
        rm -r ${ARCHIVE_PATH}
    fi
    echo "\033[;32m -------Export IPA Success------- \033[0m"
    open ${IPA_PATH}
else
    echo "\033[;31m -------Export IPA Fail------- \033[0m "
fi

echo "\033[;35;5m 请选择上传平台： \033[0m"
echo "\033[;32;m 0 APP Store 1 fim 2 蒲公英 3 Coding \033[0m"
read uploadApp
if [[ condition ]]; then
    echo "\033[;37;2m 未开发 \033[0m"
fi

## app store

## 验证
## xcrun altool --validate-app -f ${IPA_PATH}/${SCHEME_NAME}.ipa -t ios --apiKey xxx --apiIssuer xxx --verbose

## 上传
## xcrun altool --upload-app -f ${IPA_PATH}/${SCHEME_NAME}.ipa -t ios --apiKey xxx --apiIssuer xxx --verbose


## fim https://www.betaqr.com/docs/publish
## 蒲公英 http://www.pgyer.com/doc/view/api#uploadApp
## Coding https://help.coding.net/docs/artifacts/practices/cci-push-docker.html#parameter-detail

