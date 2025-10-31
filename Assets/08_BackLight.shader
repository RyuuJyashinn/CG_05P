Shader "Unlit/08_BackLight"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Color", Color) = (0.3,0.3,0.3,1)
        _AmbientIntensity ("Ambient Intensity", Range(0,1)) = 0.3
        _SpecularPower ("Specular Power", Range(1,128)) = 20
        _RimColor ("Rim Color", Color) = (0.8,0.8,1,1)  // 背光颜色
        _RimPower ("Rim Power", Range(0.1,10)) = 3.0    // 背光强度控制
        _RimIntensity ("Rim Intensity", Range(0,5)) = 2.0  // 背光亮度
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

         
            fixed4 _Color;
            fixed4 _AmbientColor;
            float _AmbientIntensity;
            float _SpecularPower;
            fixed4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPosition);
                return o;
            }

       
            fixed4 CalculateAmbient()
            {
                return _AmbientColor * _AmbientIntensity * _LightColor0;
            }

            fixed4 CalculateDiffuse(float3 worldNormal, float3 lightDir)
            {
                float intensity = saturate(dot(normalize(worldNormal), lightDir));
                return _Color * intensity * _LightColor0;
            }

      
            fixed4 CalculateSpecular(float3 worldNormal, float3 lightDir, float3 viewDir)
            {
                float3 reflectDir = reflect(-lightDir, worldNormal);
                fixed4 specular = pow(saturate(dot(reflectDir, viewDir)), _SpecularPower) * _LightColor0;
                return specular;
            }

            // 计算背光效果
            fixed4 CalculateRimLight(float3 worldNormal, float3 viewDir)
            {
                // 计算法线与视线方向的点积（背光区域）
                float rim = 1.0 - saturate(dot(normalize(worldNormal), viewDir));
                
                // 使用pow函数增强边缘效果
                rim = pow(rim, _RimPower);
                
                // 应用强度控制
                rim *= _RimIntensity;
                
                return _RimColor * rim;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);

                fixed4 ambient = CalculateAmbient();      
                fixed4 diffuse = CalculateDiffuse(worldNormal, lightDir);     
                fixed4 specular = CalculateSpecular(worldNormal, lightDir, viewDir);
                fixed4 rimLight = CalculateRimLight(worldNormal, viewDir);  // 背光效果

                // 将背光效果叠加到Phong光照上
                fixed4 finalColor = ambient + diffuse + specular + rimLight;
                return finalColor;
            }
            ENDCG
        }
    }
}