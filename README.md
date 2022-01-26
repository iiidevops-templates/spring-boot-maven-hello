# 簡易Hello world maven project

## 如何增加Sonarqube掃描(用預設的QualiyGate)
在`app/pom.xml`的檔案內plugins新增如下段落後pipeline即可運行Sonarqube掃描，(此專案Sonarqube掃描包含Unit Test)  
在Spring專案的Sonarqube掃描會在openjdk11的環境執行(目前安裝僅支援到java11)，但是對Dockerfile編寫或是部屬的網頁用任意Java版本都沒問題。
```
	<build>
		<plugins>
			<plugin>
          		<groupId>org.sonarsource.scanner.maven</groupId>
          		<artifactId>sonar-maven-plugin</artifactId>
          		<version>3.7.0.1746</version>
        	</plugin>
        	<plugin>
          		<groupId>org.jacoco</groupId>
          		<artifactId>jacoco-maven-plugin</artifactId>
          		<version>0.8.6</version>
        	</plugin>
		</plugins>
	</build>

	<profiles>
    <profile>
      <id>coverage</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <build>
        <plugins>
          <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <executions>
              <execution>
                <id>prepare-agent</id>
                <goals>
                  <goal>prepare-agent</goal>
                </goals>
              </execution>
            </executions>
          </plugin>
        </plugins>
      </build>
    </profile>
  </profiles>
```   
### 如何關閉Sonarqube UnitTest
在`SonarScan`內修改特定段落內新增`-DskipTests`即可跳過unit Test，以下為跳過unit Test範例，跳過unit Test後則不會出現覆蓋率
```
echo '========== SonarQube(Maven) =========='
cd app && mvn install -DskipTests &&
mvn clean -DskipTests verify sonar:sonar -Dsonar.host.url=http://sonarqube-server-service.default:9000\
    -Dsonar.projectName=${CICD_GIT_REPO_NAME} -Dsonar.projectKey=${CICD_GIT_REPO_NAME}\
    -Dsonar.projectVersion=${CICD_GIT_BRANCH}:${CICD_GIT_COMMIT}\
	-Dsonar.log.level=DEBUG -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=600\
	-Dsonar.login=$SONAR_TOKEN
```
jacoco Coverage 參考說明
https://dzone.com/articles/reporting-code-coverage-using-maven-and-jacoco-plu
https://blog.miniasp.com/post/2021/08/11/Spring-Boot-Maven-JaCoCo-Test-Coverage-Report-in-VSCode

若要設定其他額外的細節也可寫在`app/pom.xml`，例如排除特定資料夾(與程式碼無關的)、指定的QualityGate、Rule等等  
相關可用額外參數說明可參考[sonarscanner-for-maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

## 專案資料夾與檔案格式說明
檔案可按照需求做修改，`postman_collection_local.json`是要快速部屬時進行Postman collection測試的的檔案，測試結果會自動產生`newman-report.xml`。`openapi_local.yaml`主要是透過owasp ZAP來進行安全掃描，測試報告會自動產生`owasp-report.md`，內包含詳細的掃描內容與建議。  

| 型態 | 名稱 | 說明 | 路徑 |
| --- | --- | --- | --- |
| 資料夾 | app | 專案主要程式碼 | 根目錄 |
| 檔案 | Dockerfile.local | (可調整)本地端部屬使用 | 根目錄 |
| 檔案 | docker-compose.yaml | (可調整)本地端快速部屬使用 | 根目錄 |
| 檔案 | postman_collection_local.json | (可調整)本地端快速部屬使用(Postman collection) | 在app資料夾內 |
| 檔案 | openapi_local.yaml | (可調整)本地端快速部屬使用(openAPI文件) | 在app資料夾內 | 
| 檔案 | newman-report.xml | (自動產生)Postman collection本地端測試報告 | 在app資料夾內 |
| 檔案 | owasp-report.md | (自動產生)owasp ZAP-本地端掃描測試報告 | 在app資料夾內 |
| 資料夾 | iiidevops | :warning: devops系統測試所需檔案 | 在根目錄 |
| 檔案 | .rancher-pipeline.yml | :warning: (不可更動)devops系統測試所需檔案 | 在根目錄 |
| 檔案 | pipeline_settings.json | :warning: (不可更動)devops系統測試所需檔案 | 在iiidevops資料夾內 |
| 檔案 | postman_collection.json | (可調整)devops newman部屬測試檔案 | iiidevops/postman資料夾內 |
| 檔案 | postman_environment.json | (可調整)devops newman部屬測試檔案 | iiidevops/postman資料夾內 |
| 檔案 | Dockerfile | (可調整)devops k8s環境部屬檔案 | 根目錄 |

## iiidevops
* 專案內`.rancher-pipeline.yml`請勿更動，產品系統設計上不支援pipeline修改
* 目前系統pipeline限制，因此寫的服務請一定要在port:`8080`，資料庫類型無法更改。
* `iiidevops`資料夾內`pipeline_settings.json`請勿更動
* `postman`資料夾內則是您在devops管理網頁上的Postman-collection(newman)自動測試檔案，devops系統會以`postman`資料夾內檔案做自動測試
* `Dockerfile`內可能會看到很多本地端`Dockerfile.local`都加上前墜dockerhub，此為必須需求，為使image能從harbor上擷取出Docker Hub的image來源
