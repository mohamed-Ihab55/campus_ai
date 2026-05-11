import logging
import sys


def setup_logging(level: str = "INFO") -> None:
    """يُستدعى مرة واحدة عند بدء التطبيق."""

    formatter = logging.Formatter(
        fmt="%(asctime)s | %(levelname)-8s | %(name)-20s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, level.upper(), logging.INFO))
    root_logger.handlers.clear()
    root_logger.addHandler(handler)

    # تقليل ضجيج مكتبات خارجية
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("chromadb").setLevel(logging.WARNING)
    logging.getLogger("sentence_transformers").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    احصل على logger لأي module.

    الاستخدام:
        from app.core.logging_setup import get_logger
        logger = get_logger(__name__)
        logger.info("البيانات جاهزة")
        logger.warning("لم يتم العثور على شيء")
        logger.error("فشل الاتصال", exc_info=True)
    """
    return logging.getLogger(name)