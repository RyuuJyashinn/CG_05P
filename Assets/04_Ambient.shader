Shader "Unlit/04_Ambient"
{
        Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 暗めの_Colorに光源の色をかけた色
                fixed4 ambient = _Color * 0.3 * _LightColor0;
                return ambient;
            }
            ENDCG
        }
    }
}
