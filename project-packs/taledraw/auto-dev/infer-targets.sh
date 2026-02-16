#!/usr/bin/env bash
set -euo pipefail

force_all="${AUTO_DEV_FORCE_ALL:-0}"
setup_cloud_tasks="${AUTO_DEV_SETUP_CLOUD_TASKS:-0}"

changed_files=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  changed_files+=("$line")
done

deploy_client=false
deploy_functions_web_account=false
deploy_functions_web_reports=false
deploy_functions_web_content=false
deploy_func_core=false
deploy_portal=false
deploy_firestore=false
deploy_storage=false
setup_cloud_tasks_input=false
functions_web_all=false

if [[ "$setup_cloud_tasks" == "1" || "$setup_cloud_tasks" == "true" ]]; then
  setup_cloud_tasks_input=true
fi

if [[ "$force_all" == "1" || "$force_all" == "true" ]]; then
  deploy_client=true
  deploy_functions_web_account=true
  deploy_functions_web_reports=true
  deploy_functions_web_content=true
  deploy_func_core=true
  deploy_portal=true
  deploy_firestore=true
  deploy_storage=true
else
  for file in "${changed_files[@]}"; do
    case "$file" in
      client/*)
        deploy_client=true
        ;;
      portal/*)
        deploy_portal=true
        ;;
      func-core/*)
        deploy_func_core=true
        ;;
      firestore.rules|firestore.indexes*.json)
        deploy_firestore=true
        ;;
      storage.rules)
        deploy_storage=true
        ;;
      config/environments.json)
        deploy_client=true
        functions_web_all=true
        ;;
      config/functions-web-groups.json)
        functions_web_all=true
        ;;
      firebase.json|.firebaserc)
        deploy_client=true
        deploy_func_core=true
        functions_web_all=true
        ;;
      functions-web/*)
        case "$file" in
          functions-web/business/*)
            subpath="${file#functions-web/business/}"
            subdir="${subpath%%/*}"
            case "$subdir" in
              stripe|orders|order|credits|users)
                deploy_functions_web_account=true
                ;;
              share|featured|monitoring|analysis)
                deploy_functions_web_reports=true
                ;;
              tales|public|review|spaces|fcm|tags)
                deploy_functions_web_content=true
                ;;
              *)
                functions_web_all=true
                ;;
            esac
            ;;
          functions-web/utils/*|functions-web/config.js|functions-web/index.js|functions-web/lib/*|functions-web/package*.json|functions-web/.env*|functions-web/test/*)
            functions_web_all=true
            ;;
          *)
            functions_web_all=true
            ;;
        esac
        ;;
    esac
  done
fi

if [[ "$functions_web_all" == "true" ]]; then
  deploy_functions_web_account=true
  deploy_functions_web_reports=true
  deploy_functions_web_content=true
fi

if [[ "$deploy_client" == "false" &&
      "$deploy_functions_web_account" == "false" &&
      "$deploy_functions_web_reports" == "false" &&
      "$deploy_functions_web_content" == "false" &&
      "$deploy_func_core" == "false" &&
      "$deploy_portal" == "false" &&
      "$deploy_firestore" == "false" &&
      "$deploy_storage" == "false" ]]; then
  echo "No TaleDraw deploy targets inferred from changed files." >&2
  exit 2
fi

echo "workflow=dev.yml"
echo "input:deploy_client=$deploy_client"
echo "input:deploy_functions_web_account=$deploy_functions_web_account"
echo "input:deploy_functions_web_reports=$deploy_functions_web_reports"
echo "input:deploy_functions_web_content=$deploy_functions_web_content"
echo "input:deploy_func_core=$deploy_func_core"
echo "input:deploy_portal=$deploy_portal"
echo "input:deploy_firestore=$deploy_firestore"
echo "input:deploy_storage=$deploy_storage"
echo "input:setup_cloud_tasks=$setup_cloud_tasks_input"
