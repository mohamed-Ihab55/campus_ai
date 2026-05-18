---
title: ASU RAG Chatbot
emoji: 🎓
colorFrom: blue
colorTo: indigo
sdk: docker
app_file: main.py
pinned: false
---

# ASU RAG Chatbot 🎓

مساعد أكاديمي ذكي لطلاب كلية العلوم - جامعة عين شمس، يعتمد على تقنية **RAG (Retrieval-Augmented Generation)** لتقديم إجابات دقيقة من اللوائح والمقررات الأكاديمية.

## التحديثات الأخيرة (الإصدار السحابي - Hugging Face) 🚀
تم تحديث النظام ليكون جاهزاً للعمل على السحابة (Cloud Deployment) بأعلى كفاءة وأقل استهلاك للموارد:
- **نقل الذكاء الاصطناعي إلى السحابة**: تم استبدال نموذج Ollama المحلي ونموذج HuggingFace Reranker الثقيل بـ **Groq API** فائق السرعة.
- **توليد النصوص (LLM)**: يتم الآن استخدام نموذج llama-3.3-70b-versatile من Groq لضمان إجابات دقيقة وسريعة.
- **إعادة الترتيب (Reranking)**: يتم استخدام Groq API لترتيب النتائج (Reranking) بدلاً من النماذج المحلية لتقليل استهلاك الذاكرة (RAM/CPU) على الخادم.
- **التوافق مع Hugging Face Spaces**: تم إضافة Dockerfile وإعدادات README (YAML frontmatter) لرفع المشروع وتشغيله مباشرة عبر HF Spaces.

## تشغيل المشروع محلياً (Local Development) 💻
النظام مصمم بمرونة عالية؛ جميع الأكواد الخاصة بالتشغيل المحلي (باستخدام **Ollama**) لا تزال موجودة في الكود (مُعطلة كـ Comments). يمكنك في أي وقت إزالة الـ Comments للعودة إلى التشغيل المحلي بالكامل بدون الحاجة لإنترنت.

## الإعداد والتشغيل (Deployment)
لرفع المشروع على Hugging Face Spaces:
1. قم برفع كافة الملفات في هذا المجلد إلى الـ Repository الخاص بك على Hugging Face.
2. تأكد من تحديد نوع الـ Space كـ **Docker**.
3. اذهب إلى **Settings** > **Variables and secrets**.
4. أضف الـ Secret التالي:
   - GROQ_API_KEY: مفتاح الـ API الخاص بك من Groq.
5. (اختياري) يمكنك إضافة GROQ_MODEL وتحديد llama-3.1-8b-instant إذا واجهت مشكلة في حدود الاستخدام اليومية.

## المتطلبات (Requirements)
- astapi & uvicorn
- chromadb
- sentence-transformers (لاستخراج الـ Embeddings باستخدام CPU)
- groq (للاتصال بـ API)
