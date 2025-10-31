Shader "Unlit/08_BackLight"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Color", Color) = (0.3,0.3,0.3,1)
        _AmbientIntensity ("Ambient Intensity", Range(0,1)) = 0.3
        _SpecularPower ("Specular Power", Range(1,128)) = 20
        _RimColor ("Rim Color", Color) = (0.8,0.8,1,1)  // ������ɫ
        _RimPower ("Rim Power", Range(0.1,10)) = 3.0    // ����ǿ�ȿ���
        _RimIntensity ("Rim Intensity", Range(0,5)) = 2.0  // ��������
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

            // ���㱳��Ч��
            fixed4 CalculateRimLight(float3 worldNormal, float3 viewDir)
            {
                // ���㷨�������߷���ĵ������������
                float rim = 1.0 - saturate(dot(normalize(worldNormal), viewDir));
                
                // ʹ��pow������ǿ��ԵЧ��
                rim = pow(rim, _RimPower);
                
                // Ӧ��ǿ�ȿ���
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
                fixed4 rimLight = CalculateRimLight(worldNormal, viewDir);  // ����Ч��

                // ������Ч�����ӵ�Phong������
                fixed4 finalColor = ambient + diffuse + specular + rimLight;
                return finalColor;
            }
            ENDCG
        }
    }
}