// ---------------------------------------------------------------------
// Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// ---------------------------------------------------------------------
package com.quicinc.chatapp;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;

public class MainActivity extends AppCompatActivity {
    static {
        System.loadLibrary("chatapp");
    }

    private Toolbar toolbar;
    private ImageButton backButton;
    private ImageButton saveButton;
    private ImageButton menuButton;
    private ImageView emojiImage;
    private TextView dateText;
    private ImageView generatedImage;
    private TextView contentText;
    private View chatButton;

    void copyAssetsDir(String inputAssetRelPath, String outputPath) throws IOException, NullPointerException {
        File outputAssetPath = new File(Paths.get(outputPath, inputAssetRelPath).toString());

        String[] subAssetList = this.getAssets().list(inputAssetRelPath);
        if (subAssetList.length == 0) {
            if (!outputAssetPath.exists()) {
                copyFile(inputAssetRelPath, outputAssetPath);
            }
            return;
        }

        if (!outputAssetPath.exists()) {
            outputAssetPath.mkdirs();
        }
        for (String subAssetName : subAssetList) {
            String input_sub_asset_path = Paths.get(inputAssetRelPath, subAssetName).toString();
            copyAssetsDir(input_sub_asset_path, outputPath);
        }
    }

    void copyFile(String inputFilePath, File outputAssetFile) throws IOException {
        InputStream in = this.getAssets().open(inputFilePath);
        OutputStream out = new FileOutputStream(outputAssetFile);

        byte[] buffer = new byte[1024 * 1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            // Get SoC model from build properties
            HashMap<String, String> supportedSocModel = new HashMap<>();
            supportedSocModel.putIfAbsent("SM8750", "qualcomm-snapdragon-8-elite.json");
            supportedSocModel.putIfAbsent("SM8650", "qualcomm-snapdragon-8-gen3.json");
            supportedSocModel.putIfAbsent("QCS8550", "qualcomm-snapdragon-8-gen2.json");

            String socModel = android.os.Build.SOC_MODEL;
            if (!supportedSocModel.containsKey(socModel)) {
                String errorMsg = "Unsupported device. Please ensure you have one of the following device to run the ChatApp: " + supportedSocModel.toString();
                Log.e("ChatApp", errorMsg);
                Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show();
                finish();
            }

            // Copy assets to External cache
            String externalDir = getExternalCacheDir().getAbsolutePath();
            try {
                copyAssetsDir("models", externalDir.toString());
                copyAssetsDir("htp_config", externalDir.toString());
            } catch (IOException e) {
                String errorMsg = "Error during copying model asset to external storage: " + e.toString();
                Log.e("ChatApp", errorMsg);
                Toast.makeText(this, errorMsg, Toast.LENGTH_SHORT).show();
                finish();
            }
            Path htpExtConfigPath = Paths.get(externalDir, "htp_config", supportedSocModel.get(socModel));

            setContentView(R.layout.activity_main);

            // Initialize views
            toolbar = findViewById(R.id.toolbar);
            backButton = findViewById(R.id.backButton);
            saveButton = findViewById(R.id.saveButton);
            menuButton = findViewById(R.id.menuButton);
            emojiImage = findViewById(R.id.emojiImage);
            dateText = findViewById(R.id.dateText);
            generatedImage = findViewById(R.id.generatedImage);
            contentText = findViewById(R.id.contentText);
            chatButton = findViewById(R.id.chatButton);

            // Set up toolbar
            setSupportActionBar(toolbar);
            if (getSupportActionBar() != null) {
                getSupportActionBar().setDisplayShowTitleEnabled(false);
            }

            // Set current date
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy년 MM월 dd일", Locale.getDefault());
            dateText.setText(dateFormat.format(new Date()));

            // Set sample image
            generatedImage.setImageResource(R.drawable.chillguy);

            // Set sample content
            contentText.setText("오늘은 정말 멋진 하루였어. 기린과 함께하니 더욱 특별해!");

            // Set up click listeners
            backButton.setOnClickListener(v -> finish());

            saveButton.setOnClickListener(v -> {
                Toast.makeText(this, "저장되었습니다!", Toast.LENGTH_SHORT).show();
            });

            menuButton.setOnClickListener(v -> {
                Toast.makeText(this, "메뉴", Toast.LENGTH_SHORT).show();
            });

            final Path finalHtpExtConfigPath = htpExtConfigPath;
            chatButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = new Intent(MainActivity.this, Conversation.class);
                    intent.putExtra(Conversation.cConversationActivityKeyHtpConfig, finalHtpExtConfigPath.toString());
                    intent.putExtra(Conversation.cConversationActivityKeyModelName, "llama3_2_3b");
                    startActivity(intent);
                }
            });

        } catch (Exception e) {
            String errorMsg = "Unexpected error occurred while running ChatApp:" + e.toString();
            Log.e("ChatApp", errorMsg);
            Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show();
            finish();
        }
    }
}
